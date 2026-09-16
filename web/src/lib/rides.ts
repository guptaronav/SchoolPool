import {
  addDoc,
  collection,
  doc,
  getDoc,
  onSnapshot,
  query,
  serverTimestamp,
  Timestamp,
  updateDoc,
  where,
  type Unsubscribe,
} from 'firebase/firestore'
import { db } from './firebase'
import type { Ride, RideLocation } from '../types/models'

export function subscribeToSchoolRides(
  schoolId: string,
  onChange: (rides: Ride[]) => void,
): Unsubscribe {
  const q = query(collection(db, 'rides'), where('schoolId', '==', schoolId))
  return onSnapshot(q, (snap) => {
    const rides = snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<Ride, 'id'>) }))
    rides.sort((a, b) => a.departureTime.toMillis() - b.departureTime.toMillis())
    onChange(rides)
  })
}

export async function fetchRide(rideId: string): Promise<Ride | null> {
  const snap = await getDoc(doc(db, 'rides', rideId))
  if (!snap.exists()) return null
  return { id: snap.id, ...(snap.data() as Omit<Ride, 'id'>) }
}

export interface NewRideInput {
  driverId: string
  driverName: string
  schoolId: string
  origin: RideLocation
  destination: RideLocation
  departureTime: Date
  totalSeats: number
  pricePerSeat: number
  notes: string
}

export async function createRide(input: NewRideInput): Promise<string> {
  const ref = await addDoc(collection(db, 'rides'), {
    driverId: input.driverId,
    driverName: input.driverName,
    schoolId: input.schoolId,
    origin: input.origin,
    destination: input.destination,
    departureTime: Timestamp.fromDate(input.departureTime),
    totalSeats: input.totalSeats,
    seatsAvailable: input.totalSeats,
    pricePerSeat: input.pricePerSeat,
    status: 'open',
    passengerIds: [],
    notes: input.notes || null,
    createdAt: serverTimestamp(),
  })
  return ref.id
}

export async function joinRide(ride: Ride, userId: string) {
  if (ride.passengerIds.includes(userId) || ride.seatsAvailable <= 0) return
  const nextPassengers = [...ride.passengerIds, userId]
  const nextSeatsAvailable = ride.seatsAvailable - 1
  await updateDoc(doc(db, 'rides', ride.id), {
    passengerIds: nextPassengers,
    seatsAvailable: nextSeatsAvailable,
    status: nextSeatsAvailable === 0 ? 'full' : ride.status,
  })
}

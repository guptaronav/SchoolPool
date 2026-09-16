import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { Button } from '../../components/ui/Button'
import { fetchRide, joinRide } from '../../lib/rides'
import type { Ride, SPUser } from '../../types/models'
import './rides.css'

export function RideDetailScreen({ currentUser }: { currentUser: SPUser }) {
  const { rideId } = useParams()
  const navigate = useNavigate()
  const [ride, setRide] = useState<Ride | null | undefined>(undefined)
  const [isJoining, setJoining] = useState(false)

  useEffect(() => {
    if (rideId) fetchRide(rideId).then(setRide)
  }, [rideId])

  if (ride === undefined) return <p className="rides-empty">Loading ride…</p>
  if (ride === null) return <p className="rides-empty">Ride not found.</p>

  const isMine = ride.driverId === currentUser.id
  const alreadyJoined = ride.passengerIds.includes(currentUser.id)

  async function handleJoin() {
    if (!ride) return
    setJoining(true)
    try {
      await joinRide(ride, currentUser.id)
      setRide(await fetchRide(ride.id))
    } finally {
      setJoining(false)
    }
  }

  return (
    <div className="ride-detail">
      <button className="ride-detail__back" onClick={() => navigate('/')}>
        ← Back to rides
      </button>
      <div className="ride-detail__card">
        <h1>{ride.origin.title} → {ride.destination.title}</h1>
        <div className="ride-detail__row">
          <span>Departure</span>
          <strong>{ride.departureTime.toDate().toLocaleString()}</strong>
        </div>
        <div className="ride-detail__row">
          <span>Driver</span>
          <strong>{ride.driverName}</strong>
        </div>
        <div className="ride-detail__row">
          <span>Seats</span>
          <strong>
            {ride.seatsAvailable} of {ride.totalSeats} available
          </strong>
        </div>
        <div className="ride-detail__row">
          <span>Price</span>
          <strong>{ride.pricePerSeat > 0 ? `$${ride.pricePerSeat.toFixed(2)} / seat` : 'Free'}</strong>
        </div>
        {ride.notes && (
          <div className="ride-detail__row">
            <span>Notes</span>
            <strong>{ride.notes}</strong>
          </div>
        )}

        {isMine ? (
          <p className="rides-empty" style={{ padding: 0 }}>
            This is your ride.
          </p>
        ) : alreadyJoined ? (
          <p className="rides-empty" style={{ padding: 0 }}>
            You're booked on this ride.
          </p>
        ) : (
          <Button onClick={handleJoin} isLoading={isJoining} disabled={ride.seatsAvailable <= 0}>
            {ride.seatsAvailable <= 0 ? 'Ride Full' : 'Request a Seat'}
          </Button>
        )}
      </div>
    </div>
  )
}

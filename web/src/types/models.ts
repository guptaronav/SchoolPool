import type { Timestamp } from 'firebase/firestore'

export type UserRole = 'student' | 'parent' | 'teacher' | 'community' | 'schoolAdmin' | 'superAdmin'

export const ROLE_LABELS: Record<UserRole, string> = {
  student: 'Student',
  parent: 'Parent or Guardian',
  teacher: 'Teacher',
  community: 'Community Member',
  schoolAdmin: 'School Admin',
  superAdmin: 'Super Admin',
}

export type VerificationStatus = 'unverified' | 'pending' | 'verified' | 'rejected' | 'suspended'

export type PoolLevel = 'ripple' | 'stream' | 'river' | 'lake' | 'ocean'

export type RideStatus = 'open' | 'full' | 'inProgress' | 'completed' | 'cancelled'

export interface PrivacySettings {
  hidePhone: boolean
  hideAddress: boolean
  locationSharingConsent: boolean
}

export interface SPUser {
  id: string
  displayName: string
  email: string
  photoURL: string | null
  role: UserRole
  verificationStatus: VerificationStatus
  schoolId: string | null
  linkedGuardianIds: string[]
  linkedStudentIds: string[]
  emergencyContactName: string | null
  emergencyContactPhone: string | null
  dropletsBalance: number
  poolLevel: PoolLevel
  rideStreak: number
  createdAt: Timestamp
  lastActiveAt: Timestamp
  isEmailVerified: boolean
  notificationTokens: string[]
  privacySettings: PrivacySettings
}

export interface School {
  id: string
  name: string
  district: string | null
  city: string
  state: string
  country: string
  emailDomains: string[]
  adminUserIds: string[]
  isOnboarded: boolean
  isPending: boolean
  createdAt: Timestamp
  studentCount: number
}

export interface RideLocation {
  title: string
  subtitle: string
  latitude: number
  longitude: number
}

export interface Ride {
  id: string
  driverId: string
  driverName: string
  schoolId: string
  origin: RideLocation
  destination: RideLocation
  departureTime: Timestamp
  totalSeats: number
  seatsAvailable: number
  pricePerSeat: number
  status: RideStatus
  passengerIds: string[]
  notes: string | null
  createdAt: Timestamp
}

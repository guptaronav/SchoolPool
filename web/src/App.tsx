import { Route, Routes } from 'react-router-dom'
import { useAuthUser, useUserDoc } from './lib/auth'
import { WelcomeScreen } from './features/auth/WelcomeScreen'
import { SignInScreen } from './features/auth/SignInScreen'
import { SignUpScreen } from './features/auth/SignUpScreen'
import { OnboardingFlow } from './features/onboarding/OnboardingFlow'
import { PendingApprovalScreen } from './features/onboarding/PendingApprovalScreen'
import { SuspendedScreen } from './features/onboarding/SuspendedScreen'
import { RidesHomeScreen } from './features/rides/RidesHomeScreen'
import { CreateRideScreen } from './features/rides/CreateRideScreen'
import { RideDetailScreen } from './features/rides/RideDetailScreen'

function LoadingScreen() {
  return (
    <div style={{ display: 'grid', placeItems: 'center', minHeight: '100dvh', color: 'var(--color-text-secondary)' }}>
      Loading…
    </div>
  )
}

export default function App() {
  const authUser = useAuthUser()
  const userDoc = useUserDoc(authUser?.uid)

  // Mirrors RootView.swift's routingState: unauthenticated → onboarding → pending → suspended → verified.
  if (authUser === undefined) return <LoadingScreen />

  if (authUser === null) {
    return (
      <Routes>
        <Route path="/sign-in" element={<SignInScreen />} />
        <Route path="/sign-up" element={<SignUpScreen />} />
        <Route path="*" element={<WelcomeScreen />} />
      </Routes>
    )
  }

  if (userDoc === undefined) return <LoadingScreen />
  if (userDoc === null || userDoc.verificationStatus === 'unverified' || userDoc.verificationStatus === 'rejected') {
    return <OnboardingFlow uid={authUser.uid} userEmail={authUser.email ?? ''} />
  }
  if (userDoc.verificationStatus === 'pending') return <PendingApprovalScreen />
  if (userDoc.verificationStatus === 'suspended') return <SuspendedScreen />

  return (
    <Routes>
      <Route path="/rides/new" element={<CreateRideScreen currentUser={userDoc} />} />
      <Route path="/rides/:rideId" element={<RideDetailScreen currentUser={userDoc} />} />
      <Route path="*" element={<RidesHomeScreen currentUser={userDoc} />} />
    </Routes>
  )
}

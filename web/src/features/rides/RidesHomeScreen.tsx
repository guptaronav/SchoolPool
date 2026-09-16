import { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { subscribeToSchoolRides } from '../../lib/rides'
import type { Ride, SPUser } from '../../types/models'
import { RideCard } from './RideCard'
import './rides.css'

export function RidesHomeScreen({ currentUser }: { currentUser: SPUser }) {
  const navigate = useNavigate()
  const [rides, setRides] = useState<Ride[] | null>(null)

  useEffect(() => {
    if (!currentUser.schoolId) return
    return subscribeToSchoolRides(currentUser.schoolId, setRides)
  }, [currentUser.schoolId])

  return (
    <div className="rides-page">
      <div className="rides-header">
        <h1>Rides</h1>
        <div className="rides-header__actions">
          <button className="rides-fab" onClick={() => navigate('/rides/new')} aria-label="Create ride">
            +
          </button>
        </div>
      </div>

      {rides === null && <p className="rides-empty">Loading rides…</p>}
      {rides !== null && rides.length === 0 && (
        <p className="rides-empty">No rides posted yet at your school. Be the first to offer one!</p>
      )}

      <div className="rides-list">
        {rides?.map((ride) => (
          <RideCard key={ride.id} ride={ride} />
        ))}
      </div>
    </div>
  )
}

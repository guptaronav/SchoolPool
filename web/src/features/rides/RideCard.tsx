import { useNavigate } from 'react-router-dom'
import type { Ride } from '../../types/models'
import './rides.css'

function formatDeparture(ride: Ride) {
  return ride.departureTime.toDate().toLocaleString(undefined, {
    weekday: 'short',
    month: 'short',
    day: 'numeric',
    hour: 'numeric',
    minute: '2-digit',
  })
}

export function RideCard({ ride }: { ride: Ride }) {
  const navigate = useNavigate()
  return (
    <button className="ride-card" onClick={() => navigate(`/rides/${ride.id}`)}>
      <div className="ride-card__top">
        <span className="ride-card__time">{formatDeparture(ride)}</span>
        <span className="ride-card__price">{ride.pricePerSeat > 0 ? `$${ride.pricePerSeat.toFixed(2)}` : 'Free'}</span>
      </div>
      <div className="ride-card__route">
        <span className="ride-card__dot ride-card__dot--origin" aria-hidden />
        <span className="ride-card__route-text">{ride.origin.title}</span>
      </div>
      <div className="ride-card__route">
        <span className="ride-card__dot ride-card__dot--dest" aria-hidden />
        <span className="ride-card__route-text">{ride.destination.title}</span>
      </div>
      <div className="ride-card__meta">
        <span>👤 {ride.driverName}</span>
        <span>
          🪑 {ride.seatsAvailable} of {ride.totalSeats} seats
        </span>
      </div>
    </button>
  )
}

import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../../components/ui/Button'
import { TextField } from '../../components/ui/TextField'
import { createRide } from '../../lib/rides'
import type { SPUser } from '../../types/models'
import './rides.css'

export function CreateRideScreen({ currentUser }: { currentUser: SPUser }) {
  const navigate = useNavigate()
  const [originTitle, setOriginTitle] = useState('')
  const [destTitle, setDestTitle] = useState('')
  const [departure, setDeparture] = useState('')
  const [seats, setSeats] = useState(3)
  const [price, setPrice] = useState(0)
  const [notes, setNotes] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isLoading, setLoading] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    const departureDate = new Date(departure)
    if (!originTitle || !destTitle || !departure || departureDate <= new Date()) {
      setError('Fill in both locations and pick a departure time in the future.')
      return
    }
    if (!currentUser.schoolId) {
      setError('You need to be linked to a school before posting a ride.')
      return
    }
    setLoading(true)
    try {
      const rideId = await createRide({
        driverId: currentUser.id,
        driverName: currentUser.displayName,
        schoolId: currentUser.schoolId,
        origin: { title: originTitle, subtitle: '', latitude: 0, longitude: 0 },
        destination: { title: destTitle, subtitle: '', latitude: 0, longitude: 0 },
        departureTime: departureDate,
        totalSeats: seats,
        pricePerSeat: price,
        notes,
      })
      navigate(`/rides/${rideId}`)
    } catch {
      setError('Could not post that ride.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="ride-detail">
      <button className="ride-detail__back" onClick={() => navigate(-1)}>
        ← Back
      </button>
      <h1 style={{ marginBottom: 'var(--space-4)' }}>Post a ride</h1>
      <form className="ride-detail__card" onSubmit={handleSubmit}>
        <TextField label="Pickup location" value={originTitle} onChange={(e) => setOriginTitle(e.target.value)} required />
        <TextField label="Drop-off location" value={destTitle} onChange={(e) => setDestTitle(e.target.value)} required />
        <TextField
          label="Departure time"
          type="datetime-local"
          value={departure}
          onChange={(e) => setDeparture(e.target.value)}
          required
        />
        <TextField
          label="Seats available (1–7)"
          type="number"
          min={1}
          max={7}
          value={seats}
          onChange={(e) => setSeats(Number(e.target.value))}
        />
        <TextField
          label="Price per seat ($)"
          type="number"
          min={0}
          step={0.5}
          value={price}
          onChange={(e) => setPrice(Number(e.target.value))}
        />
        <TextField label="Notes (optional)" value={notes} onChange={(e) => setNotes(e.target.value)} />
        {error && <p style={{ color: 'var(--color-danger)' }}>{error}</p>}
        <Button type="submit" isLoading={isLoading}>
          Post Ride
        </Button>
      </form>
    </div>
  )
}

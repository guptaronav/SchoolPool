import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../../components/ui/Button'
import { Logo } from '../../components/ui/Logo'
import { signInAsGuest } from '../../lib/auth'
import './welcome.css'

export function WelcomeScreen() {
  const navigate = useNavigate()
  const [isGuestLoading, setGuestLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  async function handleGuestSignIn() {
    setError(null)
    setGuestLoading(true)
    try {
      await signInAsGuest()
    } catch {
      setError('Could not start a guest session. Try again.')
    } finally {
      setGuestLoading(false)
    }
  }

  return (
    <div className="welcome">
      <div className="welcome__glow" aria-hidden />
      <div className="welcome__hero">
        <div className="welcome__logo">
          <Logo size={80} />
        </div>
        <h1 className="welcome__title">SchoolPool</h1>
        <p className="welcome__tagline">Pool together. Lift each other.</p>
      </div>

      <div className="welcome__actions">
        {error && <p className="welcome__error">{error}</p>}
        <Button onClick={() => navigate('/sign-up')}>Get Started</Button>
        <Button variant="secondary" onClick={() => navigate('/sign-in')}>
          Sign In
        </Button>
        <Button variant="danger" onClick={handleGuestSignIn} isLoading={isGuestLoading}>
          🧪 Try it — Guest Demo
        </Button>
      </div>
    </div>
  )
}

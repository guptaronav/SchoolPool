import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../../components/ui/Button'
import { TextField } from '../../components/ui/TextField'
import { signInWithEmail, signInWithGoogle } from '../../lib/auth'
import { AuthCard } from './AuthCard'

export function SignInScreen() {
  const navigate = useNavigate()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isLoading, setLoading] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    setLoading(true)
    try {
      await signInWithEmail(email, password)
      navigate('/')
    } catch {
      setError('Could not sign in with those details.')
    } finally {
      setLoading(false)
    }
  }

  async function handleGoogle() {
    setError(null)
    setLoading(true)
    try {
      await signInWithGoogle()
      navigate('/')
    } catch {
      setError('Google sign-in failed or was cancelled.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <AuthCard title="Welcome back" subtitle="Sign in to your SchoolPool account">
      <form className="auth-card__form" onSubmit={handleSubmit}>
        <TextField label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <TextField
          label="Password"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        {error && <p className="auth-card__error">{error}</p>}
        <Button type="submit" isLoading={isLoading}>
          Sign In
        </Button>
      </form>
      <div className="auth-card__divider">or</div>
      <Button variant="secondary" onClick={handleGoogle} className="auth-card__google">
        Continue with Google
      </Button>
    </AuthCard>
  )
}

import { useState, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../../components/ui/Button'
import { TextField } from '../../components/ui/TextField'
import { signInWithGoogle, signUpWithEmail } from '../../lib/auth'
import { AuthCard } from './AuthCard'

export function SignUpScreen() {
  const navigate = useNavigate()
  const [displayName, setDisplayName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [isLoading, setLoading] = useState(false)

  async function handleSubmit(e: FormEvent) {
    e.preventDefault()
    setError(null)
    if (password.length < 8) {
      setError('Password needs at least 8 characters.')
      return
    }
    setLoading(true)
    try {
      await signUpWithEmail(email, password, displayName)
      navigate('/')
    } catch {
      setError('Could not create that account.')
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
    <AuthCard title="Create account" subtitle="Join your school community">
      <form className="auth-card__form" onSubmit={handleSubmit}>
        <TextField label="Display Name" value={displayName} onChange={(e) => setDisplayName(e.target.value)} required />
        <TextField label="Email" type="email" value={email} onChange={(e) => setEmail(e.target.value)} required />
        <TextField
          label="Password (min 8 characters)"
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          required
        />
        {error && <p className="auth-card__error">{error}</p>}
        <Button type="submit" isLoading={isLoading}>
          Create Account
        </Button>
      </form>
      <div className="auth-card__divider">or</div>
      <Button variant="secondary" onClick={handleGoogle} className="auth-card__google">
        Continue with Google
      </Button>
    </AuthCard>
  )
}

import { useState } from 'react'
import { getAuth, reload, sendEmailVerification } from 'firebase/auth'
import { Button } from '../../components/ui/Button'
import './onboarding.css'

export function EmailWaitingScreen({ onVerified }: { onVerified: () => void }) {
  const [isChecking, setChecking] = useState(false)

  async function handleCheck() {
    setChecking(true)
    try {
      const user = getAuth().currentUser
      if (user) {
        await reload(user)
        if (user.emailVerified) onVerified()
      }
    } finally {
      setChecking(false)
    }
  }

  async function handleResend() {
    const user = getAuth().currentUser
    if (user) await sendEmailVerification(user)
  }

  return (
    <div className="onboarding-page">
      <span className="onboarding-icon" aria-hidden>
        📧
      </span>
      <h1>Check your email</h1>
      <p className="onboarding-page__subtitle" style={{ maxWidth: '38ch' }}>
        We sent a verification link to your school email. Click it, then come back here.
      </p>
      <div className="onboarding-form">
        <Button onClick={handleCheck} isLoading={isChecking}>
          I've verified my email
        </Button>
        <Button variant="secondary" onClick={handleResend}>
          Resend email
        </Button>
      </div>
    </div>
  )
}

import { signOut } from '../../lib/auth'
import { Button } from '../../components/ui/Button'
import './onboarding.css'

export function SuspendedScreen() {
  return (
    <div className="onboarding-page" style={{ justifyContent: 'center', flex: 1 }}>
      <span className="onboarding-icon" aria-hidden>
        ⛔️
      </span>
      <h1>Account suspended</h1>
      <p className="onboarding-page__subtitle">Contact your school admin if you think this is a mistake.</p>
      <div className="onboarding-form">
        <Button variant="secondary" onClick={() => signOut()}>
          Sign Out
        </Button>
      </div>
    </div>
  )
}

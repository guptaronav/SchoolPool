import { signOut } from '../../lib/auth'
import './onboarding.css'

export function PendingApprovalScreen() {
  return (
    <div className="onboarding-page" style={{ position: 'relative', justifyContent: 'center', flex: 1 }}>
      <button className="onboarding-signout" onClick={() => signOut()}>
        Sign Out
      </button>
      <span className="onboarding-icon" aria-hidden>
        🕐
      </span>
      <h1>Request submitted!</h1>
      <p className="onboarding-page__subtitle" style={{ maxWidth: '38ch' }}>
        A school admin is reviewing your verification request. You'll be notified when it's approved — this usually
        takes 1–2 business days.
      </p>
    </div>
  )
}

import type { UserRole } from '../../types/models'
import './onboarding.css'

const ROLES: { role: UserRole; label: string; blurb: string; icon: string }[] = [
  { role: 'student', label: 'Student', blurb: "I'm a student at this school", icon: '🎓' },
  { role: 'parent', label: 'Parent or Guardian', blurb: "I'm a parent or guardian", icon: '👨‍👩‍👧' },
  { role: 'teacher', label: 'Teacher', blurb: "I'm a teacher or staff member", icon: '📖' },
  { role: 'community', label: 'Community Member', blurb: "I'm a community member", icon: '👥' },
]

export function RoleSelectScreen({ onSelect }: { onSelect: (role: UserRole) => void }) {
  return (
    <div className="onboarding-page">
      <h1>Who are you?</h1>
      <p className="onboarding-page__subtitle">Select your role to get started</p>
      <div className="role-grid">
        {ROLES.map(({ role, label, blurb, icon }) => (
          <button key={role} className="role-card" onClick={() => onSelect(role)}>
            <span className="role-card__icon" aria-hidden>
              {icon}
            </span>
            <span className="role-card__label">{label}</span>
            <span className="role-card__blurb">{blurb}</span>
          </button>
        ))}
      </div>
    </div>
  )
}

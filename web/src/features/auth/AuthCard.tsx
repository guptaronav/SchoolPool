import type { ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { Logo } from '../../components/ui/Logo'
import './auth-card.css'

export function AuthCard({
  title,
  subtitle,
  children,
}: {
  title: string
  subtitle: string
  children: ReactNode
}) {
  const navigate = useNavigate()
  return (
    <div className="auth-card-page">
      <button className="auth-card__cancel" onClick={() => navigate('/')}>
        Cancel
      </button>
      <div className="auth-card__icon">
        <Logo size={56} color="var(--color-primary)" />
      </div>
      <h1 className="auth-card__title">{title}</h1>
      <p className="auth-card__subtitle">{subtitle}</p>
      {children}
    </div>
  )
}

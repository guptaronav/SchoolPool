import type { ButtonHTMLAttributes } from 'react'
import './button.css'

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'secondary' | 'danger' | 'ghost'
  isLoading?: boolean
}

export function Button({ variant = 'primary', isLoading, children, className, disabled, ...rest }: ButtonProps) {
  return (
    <button
      className={`sp-button sp-button--${variant} ${className ?? ''}`}
      disabled={disabled || isLoading}
      {...rest}
    >
      {isLoading ? <span className="sp-button__spinner" aria-hidden /> : null}
      <span>{children}</span>
    </button>
  )
}

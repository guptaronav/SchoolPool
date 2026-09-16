import type { InputHTMLAttributes } from 'react'
import './text-field.css'

interface TextFieldProps extends InputHTMLAttributes<HTMLInputElement> {
  label: string
}

export function TextField({ label, id, ...rest }: TextFieldProps) {
  const fieldId = id ?? label.toLowerCase().replace(/\s+/g, '-')
  return (
    <div className="sp-field">
      <label htmlFor={fieldId}>{label}</label>
      <input id={fieldId} {...rest} />
    </div>
  )
}

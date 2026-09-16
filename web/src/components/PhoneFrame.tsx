import type { ReactNode } from 'react'
import './phone-frame.css'

export function PhoneFrame({ children }: { children: ReactNode }) {
  return (
    <div className="phone-backdrop">
      <div className="phone-backdrop__blurb">
        <h2>SchoolPool</h2>
        <p>A carpool-matching app for school communities, running live against the real backend.</p>
      </div>
      <div className="device">
        <div className="device__notch" aria-hidden />
        <div className="device__screen">{children}</div>
      </div>
    </div>
  )
}

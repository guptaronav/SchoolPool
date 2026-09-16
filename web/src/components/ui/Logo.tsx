export function Logo({ size = 72, color = 'white' }: { size?: number; color?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 56 56" fill="none" xmlns="http://www.w3.org/2000/svg">
      {/* back car, partially hidden behind the front one */}
      <rect x="4" y="28" width="24" height="11" rx="5.5" fill={color} opacity="0.55" />
      <rect x="9" y="19" width="14" height="11" rx="5" fill={color} opacity="0.55" />
      <circle cx="11" cy="40" r="3.4" fill="var(--logo-wheel, #0B4C46)" opacity="0.55" />
      <circle cx="23" cy="40" r="3.4" fill="var(--logo-wheel, #0B4C46)" opacity="0.55" />

      {/* front car */}
      <rect x="18" y="32" width="30" height="13" rx="6.5" fill={color} />
      <rect x="25" y="21" width="16" height="13" rx="5.5" fill={color} />
      <circle cx="25" cy="46" r="4.4" fill="var(--logo-wheel, #0B4C46)" />
      <circle cx="41" cy="46" r="4.4" fill="var(--logo-wheel, #0B4C46)" />
    </svg>
  )
}

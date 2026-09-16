export function Logo({ size = 72, color = 'white' }: { size?: number; color?: string }) {
  return (
    <svg width={size} height={size} viewBox="0 0 64 64" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path
        d="M10 40c0-2 1-3.5 2.5-4.5l3-8.5c1-3 2.5-4 5.5-4h6c1.5 0 2.5.5 3 2l2 6.5c2 .5 3 2 3 4v7c0 1-1 2-2 2h-1.5c-.5 0-1-.4-1-1v-1h-15v1c0 .6-.5 1-1 1H13c-1.5 0-3-1-3-2.5z"
        fill={color}
      />
      <circle cx="17" cy="41" r="3" fill="var(--color-primary, #1A8C80)" />
      <path
        d="M24 44c0-2 1.2-3.8 2.8-4.9l3.3-9.3c1.1-3.3 2.8-4.4 6-4.4h8c1.8 0 3 .6 3.6 2.4l2.4 7.3c2.2.6 3.4 2.2 3.4 4.4v7.6c0 1.1-1 2.1-2.1 2.1h-1.7c-.6 0-1.1-.5-1.1-1.1v-1H30.8v1c0 .6-.5 1.1-1.1 1.1H26.1c-1.7 0-3.1-1.1-3.1-2.7z"
        fill={color}
      />
      <circle cx="33" cy="45.5" r="3.4" fill="var(--color-primary, #1A8C80)" />
      <circle cx="47" cy="45.5" r="3.4" fill="var(--color-primary, #1A8C80)" />
      <rect x="34" y="34" width="10" height="2.4" rx="1.2" fill="var(--color-primary, #1A8C80)" />
    </svg>
  )
}

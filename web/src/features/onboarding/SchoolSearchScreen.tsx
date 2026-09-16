import { useEffect, useState } from 'react'
import { searchSchools } from '../../lib/schools'
import type { School } from '../../types/models'
import './onboarding.css'

export function SchoolSearchScreen({ onSelect }: { onSelect: (school: School) => void }) {
  const [query, setQuery] = useState('')
  const [schools, setSchools] = useState<School[]>([])
  const [isLoading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    setLoading(true)
    searchSchools(query).then((results) => {
      if (!cancelled) {
        setSchools(results)
        setLoading(false)
      }
    })
    return () => {
      cancelled = true
    }
  }, [query])

  return (
    <div className="onboarding-page">
      <h1>Find your school</h1>
      <p className="onboarding-page__subtitle">Search for your school to connect with your community</p>
      <input
        className="search-input"
        placeholder="Type school name..."
        value={query}
        onChange={(e) => setQuery(e.target.value)}
      />
      {!isLoading && schools.length === 0 && (
        <p className="onboarding-empty">
          No schools found yet — schools are added by administrators, so yours may not be listed here.
        </p>
      )}
      <div className="school-list">
        {schools.map((school) => (
          <button key={school.id} className="school-row" onClick={() => onSelect(school)}>
            <span className="school-row__name">{school.name}</span>
            <span className="school-row__meta">
              {school.city}, {school.state}
            </span>
          </button>
        ))}
      </div>
    </div>
  )
}

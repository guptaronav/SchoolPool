import { useState, type FormEvent } from 'react'
import { Button } from '../../components/ui/Button'
import './onboarding.css'

export function DocumentUploadScreen({
  isLoading,
  error,
  onSubmit,
}: {
  isLoading: boolean
  error: string | null
  onSubmit: (studentId: string, file: File | null) => void
}) {
  const [studentId, setStudentId] = useState('')
  const [file, setFile] = useState<File | null>(null)

  function handleSubmit(e: FormEvent) {
    e.preventDefault()
    onSubmit(studentId, file)
  }

  return (
    <div className="onboarding-page">
      <span className="onboarding-icon" aria-hidden>
        🪪
      </span>
      <h1>Verify your ID</h1>
      <p className="onboarding-page__subtitle">
        Upload a photo of your student ID so we can confirm you belong to this school
      </p>
      <form className="onboarding-form" onSubmit={handleSubmit}>
        <input
          className="search-input"
          placeholder="Student ID number"
          value={studentId}
          onChange={(e) => setStudentId(e.target.value)}
        />
        <label className="file-drop">
          {file ? file.name : 'Tap to choose a photo of your ID'}
          <input type="file" accept="image/*" onChange={(e) => setFile(e.target.files?.[0] ?? null)} />
        </label>
        {error && <p style={{ color: 'var(--color-danger)' }}>{error}</p>}
        <Button type="submit" isLoading={isLoading}>
          Submit for Review
        </Button>
      </form>
    </div>
  )
}

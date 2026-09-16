import { addDoc, Bytes, collection, doc, serverTimestamp, updateDoc } from 'firebase/firestore'
import { useState } from 'react'
import { db } from '../../lib/firebase'
import type { School, UserRole } from '../../types/models'

export type OnboardingStep = 'role' | 'school' | 'emailWaiting' | 'documentUpload' | 'pendingReview'

async function sha256Hex(input: string): Promise<string> {
  const data = new TextEncoder().encode(input)
  const hashBuffer = await crypto.subtle.digest('SHA-256', data)
  return Array.from(new Uint8Array(hashBuffer))
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('')
}

export function useOnboardingFlow(uid: string, userEmail: string) {
  const [step, setStep] = useState<OnboardingStep>('role')
  const [selectedRole, setSelectedRole] = useState<UserRole | null>(null)
  const [selectedSchool, setSelectedSchool] = useState<School | null>(null)
  const [isLoading, setLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)

  // Role is UI-only, same as the iOS client — the Firestore rule pins new
  // accounts to 'student' and self-updates to `role` are blocked entirely.
  function selectRole(role: UserRole) {
    setSelectedRole(role)
    setStep('school')
  }

  function selectSchool(school: School) {
    setSelectedSchool(school)
    const domain = userEmail.split('@').pop()?.toLowerCase() ?? ''
    const matches = school.emailDomains.some((d) => d.toLowerCase() === domain)
    setStep(school.isOnboarded && matches ? 'emailWaiting' : 'documentUpload')
  }

  async function submitDocuments(studentId: string, file: File | null) {
    setError(null)
    if (!file) {
      setError('Please attach a photo of your student ID.')
      return
    }
    if (!studentId.trim()) {
      setError('Please enter your student ID.')
      return
    }
    setLoading(true)
    try {
      const buffer = await file.arrayBuffer()
      if (buffer.byteLength > 900_000) {
        setError('That photo is too large. Try a smaller image.')
        return
      }
      const idHash = await sha256Hex(studentId)

      await updateDoc(doc(db, 'users', uid), {
        verificationStatus: 'pending',
        ...(selectedSchool ? { schoolId: selectedSchool.id } : {}),
      })

      await addDoc(collection(db, 'verificationRequests'), {
        userId: uid,
        schoolId: selectedSchool?.id ?? null,
        schoolNameFreeText: selectedSchool?.name ?? null,
        studentIdNumberHash: idHash,
        documentImages: [Bytes.fromUint8Array(new Uint8Array(buffer))],
        status: 'pending',
        reviewedByAdminId: null,
        reviewNote: null,
        submittedAt: serverTimestamp(),
        reviewedAt: null,
      })
      setStep('pendingReview')
    } catch {
      setError('Could not submit your verification request.')
    } finally {
      setLoading(false)
    }
  }

  return { step, selectedRole, selectedSchool, isLoading, error, selectRole, selectSchool, submitDocuments }
}

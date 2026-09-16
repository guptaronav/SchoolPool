import {
  createUserWithEmailAndPassword,
  GoogleAuthProvider,
  onAuthStateChanged,
  signInAnonymously,
  signInWithEmailAndPassword,
  signInWithPopup,
  signOut as firebaseSignOut,
  updateProfile,
  type User,
} from 'firebase/auth'
import { doc, getDoc, serverTimestamp, setDoc, Timestamp } from 'firebase/firestore'
import { useEffect, useState } from 'react'
import { auth, db } from './firebase'
import type { SPUser } from '../types/models'

export function useAuthUser() {
  const [user, setUser] = useState<User | null | undefined>(undefined)

  useEffect(() => onAuthStateChanged(auth, setUser), [])

  return user
}

/** Creates the user doc only when it's confirmed absent, mirroring the iOS client's bootstrap. */
async function ensureUserDoc(uid: string, email = '', displayName = '') {
  const ref = doc(db, 'users', uid)
  const existing = await getDoc(ref)
  if (existing.exists()) return

  const newUser: Omit<SPUser, 'id' | 'createdAt' | 'lastActiveAt'> & {
    createdAt: ReturnType<typeof serverTimestamp>
    lastActiveAt: ReturnType<typeof serverTimestamp>
  } = {
    displayName: displayName || 'New User',
    email,
    photoURL: null,
    role: 'student',
    verificationStatus: 'unverified',
    schoolId: null,
    linkedGuardianIds: [],
    linkedStudentIds: [],
    emergencyContactName: null,
    emergencyContactPhone: null,
    dropletsBalance: 0,
    poolLevel: 'ripple',
    rideStreak: 0,
    createdAt: serverTimestamp(),
    lastActiveAt: serverTimestamp(),
    isEmailVerified: false,
    notificationTokens: [],
    privacySettings: { hidePhone: true, hideAddress: true, locationSharingConsent: false },
  }
  await setDoc(ref, newUser)
}

export async function signInWithGoogle() {
  const result = await signInWithPopup(auth, new GoogleAuthProvider())
  await ensureUserDoc(result.user.uid, result.user.email ?? '', result.user.displayName ?? '')
}

export async function signInWithEmail(email: string, password: string) {
  await signInWithEmailAndPassword(auth, email, password)
}

export async function signUpWithEmail(email: string, password: string, displayName: string) {
  const result = await createUserWithEmailAndPassword(auth, email, password)
  await updateProfile(result.user, { displayName })
  await ensureUserDoc(result.user.uid, email, displayName)
}

/** Debug-style mock login — no credentials, same as the iOS app's testing shortcut. */
export async function signInAsGuest() {
  const result = await signInAnonymously(auth)
  await ensureUserDoc(result.user.uid)
}

export async function signOut() {
  await firebaseSignOut(auth)
}

export async function fetchUserDoc(uid: string): Promise<SPUser | null> {
  const snap = await getDoc(doc(db, 'users', uid))
  if (!snap.exists()) return null
  return { id: snap.id, ...(snap.data() as Omit<SPUser, 'id'>) }
}

export function useUserDoc(uid: string | null | undefined) {
  const [userDoc, setUserDoc] = useState<SPUser | null | undefined>(undefined)

  useEffect(() => {
    if (!uid) {
      setUserDoc(null)
      return
    }
    setUserDoc(undefined)
    fetchUserDoc(uid).then(setUserDoc)
  }, [uid])

  return userDoc
}

export function tsToDate(ts: Timestamp | undefined | null): Date | null {
  return ts ? ts.toDate() : null
}

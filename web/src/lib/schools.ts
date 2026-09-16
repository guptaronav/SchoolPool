import { collection, doc, getDoc, getDocs } from 'firebase/firestore'
import { db } from './firebase'
import type { School } from '../types/models'

/** Schools are read-only from the client — creation is admin/functions-managed only. */
export async function searchSchools(query: string): Promise<School[]> {
  const snap = await getDocs(collection(db, 'schools'))
  const all = snap.docs.map((d) => ({ id: d.id, ...(d.data() as Omit<School, 'id'>) }))
  const q = query.trim().toLowerCase()
  if (!q) return all
  return all.filter((s) => s.name.toLowerCase().includes(q))
}

export async function fetchSchool(schoolId: string): Promise<School | null> {
  const snap = await getDoc(doc(db, 'schools', schoolId))
  if (!snap.exists()) return null
  return { id: snap.id, ...(snap.data() as Omit<School, 'id'>) }
}

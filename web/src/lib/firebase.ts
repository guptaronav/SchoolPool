import { initializeApp } from 'firebase/app'
import { getAuth } from 'firebase/auth'
import { getFirestore } from 'firebase/firestore'

// Firebase's web config identifies the project to Google's servers — it is not
// a secret. Access is enforced by Firestore/Auth security rules, not by hiding this.
const firebaseConfig = {
  apiKey: 'AIzaSyClPLkp_xd-NK_JPD9XZjtpeuCYJ5ZotZk',
  authDomain: 'schoolpool-13522.firebaseapp.com',
  projectId: 'schoolpool-13522',
  storageBucket: 'schoolpool-13522.firebasestorage.app',
  messagingSenderId: '46178475853',
  appId: '1:46178475853:web:215571cc0bb441246c6104',
}

const app = initializeApp(firebaseConfig)

export const auth = getAuth(app)
export const db = getFirestore(app)

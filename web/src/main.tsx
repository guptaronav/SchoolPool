import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { HashRouter } from 'react-router-dom'
import './styles/global.css'
import App from './App.tsx'
import { PhoneFrame } from './components/PhoneFrame.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <HashRouter>
      <PhoneFrame>
        <App />
      </PhoneFrame>
    </HashRouter>
  </StrictMode>,
)

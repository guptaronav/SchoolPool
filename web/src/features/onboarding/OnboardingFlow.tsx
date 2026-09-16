import { DocumentUploadScreen } from './DocumentUploadScreen'
import { EmailWaitingScreen } from './EmailWaitingScreen'
import { PendingApprovalScreen } from './PendingApprovalScreen'
import { RoleSelectScreen } from './RoleSelectScreen'
import { SchoolSearchScreen } from './SchoolSearchScreen'
import { useOnboardingFlow } from './useOnboardingFlow'

export function OnboardingFlow({ uid, userEmail }: { uid: string; userEmail: string }) {
  const flow = useOnboardingFlow(uid, userEmail)

  switch (flow.step) {
    case 'role':
      return <RoleSelectScreen onSelect={flow.selectRole} />
    case 'school':
      return <SchoolSearchScreen onSelect={flow.selectSchool} />
    case 'emailWaiting':
      // RootRouter re-reads the user doc once signed in and picks up the
      // verification state change on its own, same as the iOS RootView.
      return <EmailWaitingScreen onVerified={() => window.location.reload()} />
    case 'documentUpload':
      return <DocumentUploadScreen isLoading={flow.isLoading} error={flow.error} onSubmit={flow.submitDocuments} />
    case 'pendingReview':
      return <PendingApprovalScreen />
  }
}

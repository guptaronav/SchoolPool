import SwiftUI

struct WelcomeView: View {
    @ObservedObject var vm: AuthViewModel
    @State private var showSignIn = false
    @State private var showSignUp = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [Color.spPrimary.opacity(0.85), Color.spAccent.opacity(0.6), Color.spBackground],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                // Logo area
                VStack(spacing: 16) {
                    Image(systemName: "car.2.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(.white)
                        .shadow(radius: 8)

                    Text("SchoolPool")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)

                    Text("Pool together. Lift each other.")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }

                Spacer()

                // CTA buttons
                VStack(spacing: 12) {
                    SPButton(title: "Get Started") { showSignUp = true }

                    SPButton(title: "Sign In", style: .secondary) { showSignIn = true }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 48)
            }
        }
        .sheet(isPresented: $showSignIn) {
            SignInView(vm: vm)
        }
        .sheet(isPresented: $showSignUp) {
            SignUpView(vm: vm)
        }
    }
}

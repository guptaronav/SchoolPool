import SwiftUI

struct MainTabView: View {
    let userId: String
    let userRepo: UserRepositoryProtocol
    let onSignOut: () -> Void

    var body: some View {
        TabView {
            // Placeholder tabs
            Text("Home").tabItem { Label("Home", systemImage: "house.fill") }
            Text("Rides").tabItem { Label("Rides", systemImage: "car.fill") }
            Text("Events").tabItem { Label("Events", systemImage: "calendar") }
            Text("Messages").tabItem { Label("Messages", systemImage: "message.fill") }

            // Functional profile tab
            ProfileView(userId: userId, userRepo: userRepo, onSignOut: onSignOut)
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(Color.spPrimary)
    }
}

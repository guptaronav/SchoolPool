import Foundation
import UserNotifications
@preconcurrency import FirebaseMessaging
import UIKit

/// Bridges APNs / FCM registration to the signed-in user's token list.
///
/// Register as the FCM + notification-center delegate at launch, then call
/// `attach(userId:)` once auth resolves so tokens land on the right user doc.
@MainActor
final class PushNotificationManager: NSObject {
    static let shared = PushNotificationManager()

    private var userRepo: UserRepositoryProtocol?
    private var currentUserId: String?
    private var lastToken: String?

    func configure(userRepo: UserRepositoryProtocol) {
        self.userRepo = userRepo
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            guard granted else { return }
            UIApplication.shared.registerForRemoteNotifications()
        } catch {
            // Authorization failures are non-fatal; the app works without push.
        }
    }

    /// Associate the current FCM token with a user once they sign in.
    func attach(userId: String) {
        currentUserId = userId
        if let token = lastToken {
            persist(token: token, for: userId)
        }
    }

    /// Remove the current device token from a user before sign-out.
    func detach() async {
        guard let userId = currentUserId, let token = lastToken else { return }
        try? await userRepo?.removeNotificationToken(token, for: userId)
        currentUserId = nil
    }

    private func persist(token: String, for userId: String) {
        Task { try? await userRepo?.addNotificationToken(token, for: userId) }
    }
}

extension PushNotificationManager: MessagingDelegate {
    nonisolated func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task { @MainActor in
            self.lastToken = fcmToken
            if let userId = self.currentUserId {
                self.persist(token: fcmToken, for: userId)
            }
        }
    }
}

extension PushNotificationManager: UNUserNotificationCenterDelegate {
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .badge, .sound]
    }
}

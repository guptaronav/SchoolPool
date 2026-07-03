@preconcurrency import FirebaseFirestore

struct ChatMessage: Codable, Identifiable, Sendable {
    @DocumentID var id: String?
    var rideId: String
    var senderId: String
    var senderName: String
    var text: String
    var sentAt: Timestamp

    func isMine(_ userId: String) -> Bool { senderId == userId }
}

#if DEBUG
extension ChatMessage {
    static func stub(
        rideId: String = "ride_001",
        senderId: String = "user_001",
        senderName: String = "Alex Johnson",
        text: String = "On my way!",
        sentAt: Timestamp = Timestamp()
    ) -> ChatMessage {
        ChatMessage(
            rideId: rideId,
            senderId: senderId,
            senderName: senderName,
            text: text,
            sentAt: sentAt
        )
    }
}
#endif

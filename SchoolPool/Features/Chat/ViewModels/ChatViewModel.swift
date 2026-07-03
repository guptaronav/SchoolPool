import Foundation
import Combine
@preconcurrency import FirebaseFirestore

@MainActor
final class ChatViewModel: ObservableObject {
    @Published private(set) var messages: [ChatMessage] = []
    @Published var draft = ""
    @Published var errorMessage: String?

    let currentUserId: String

    private let rideId: String
    private let currentUserName: String
    private let chatService: ChatServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(rideId: String, currentUserId: String, currentUserName: String, chatService: ChatServiceProtocol) {
        self.rideId = rideId
        self.currentUserId = currentUserId
        self.currentUserName = currentUserName
        self.chatService = chatService
    }

    var canSend: Bool {
        !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func start() {
        guard cancellables.isEmpty else { return }
        chatService.observeMessages(rideId: rideId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.messages = items
            }
            .store(in: &cancellables)
    }

    func send() async {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }

        let message = ChatMessage(
            rideId: rideId,
            senderId: currentUserId,
            senderName: currentUserName,
            text: text,
            sentAt: Timestamp()
        )
        draft = ""
        do {
            try await chatService.send(message)
        } catch {
            draft = text
            errorMessage = error.localizedDescription
        }
    }
}

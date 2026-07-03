import XCTest
@testable import SchoolPool

@MainActor
final class ChatViewModelTests: XCTestCase {

    private func makeVM(service: MockChatService = MockChatService()) -> ChatViewModel {
        ChatViewModel(
            rideId: "ride_001",
            currentUserId: "user_001",
            currentUserName: "Alex Johnson",
            chatService: service
        )
    }

    func test_initialState_hasEmptyDraftAndCannotSend() {
        let vm = makeVM()
        XCTAssertFalse(vm.canSend)
    }

    func test_canSend_whenDraftHasContent() {
        let vm = makeVM()
        vm.draft = "Hi there"
        XCTAssertTrue(vm.canSend)
    }

    func test_canSend_falseForWhitespaceOnly() {
        let vm = makeVM()
        vm.draft = "   \n  "
        XCTAssertFalse(vm.canSend)
    }

    func test_send_appendsMessageAndClearsDraft() async {
        let service = MockChatService()
        let vm = makeVM(service: service)
        vm.draft = "On my way"
        await vm.send()

        XCTAssertEqual(service.sendCallCount, 1)
        XCTAssertEqual(vm.draft, "")
        XCTAssertEqual(service.messagesStore["ride_001"]?.first?.text, "On my way")
        XCTAssertEqual(service.messagesStore["ride_001"]?.first?.senderId, "user_001")
    }

    func test_send_doesNothingWhenDraftEmpty() async {
        let service = MockChatService()
        let vm = makeVM(service: service)
        await vm.send()
        XCTAssertEqual(service.sendCallCount, 0)
    }

    func test_observe_populatesMessages() async {
        let service = MockChatService()
        service.messagesStore["ride_001"] = [.stub(text: "Hello")]
        let vm = makeVM(service: service)
        vm.start()

        // Allow the Combine sink to deliver on the main queue.
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(vm.messages.count, 1)
        XCTAssertEqual(vm.messages.first?.text, "Hello")
    }
}

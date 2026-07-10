import SwiftUI

struct ChatView: View {
    @StateObject private var vm: ChatViewModel
    @FocusState private var inputFocused: Bool

    init(rideId: String, user: SPUser, chatService: ChatServiceProtocol) {
        _vm = StateObject(wrappedValue: ChatViewModel(
            rideId: rideId,
            currentUserId: user.id ?? "",
            currentUserName: user.displayName,
            chatService: chatService
        ))
    }

    var body: some View {
        VStack(spacing: 0) {
            messageScroll
            composer
        }
        .background(Color.spBackground)
        .navigationTitle("Ride Chat")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { vm.start() }
        .onDisappear { vm.stop() }
    }

    private var messageScroll: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(vm.messages) { message in
                        MessageBubble(message: message, isMine: message.isMine(vm.currentUserId))
                            .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .onChange(of: vm.messages.count) { _, _ in
                if let lastId = vm.messages.last?.id {
                    withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                }
            }
        }
    }

    private var composer: some View {
        HStack(spacing: 10) {
            TextField("Message", text: $vm.draft, axis: .vertical)
                .lineLimit(1...4)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.spSurface)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .focused($inputFocused)

            Button {
                Task { await vm.send() }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(vm.canSend ? Color.spPrimary : Color.spTextSecondary.opacity(0.4))
            }
            .disabled(!vm.canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.thinMaterial)
    }
}

private struct MessageBubble: View {
    let message: ChatMessage
    let isMine: Bool

    var body: some View {
        HStack {
            if isMine { Spacer(minLength: 40) }
            VStack(alignment: isMine ? .trailing : .leading, spacing: 2) {
                if !isMine {
                    Text(message.senderName)
                        .font(.caption2)
                        .foregroundStyle(Color.spTextSecondary)
                }
                Text(message.text)
                    .font(.subheadline)
                    .foregroundStyle(isMine ? .white : Color.spTextPrimary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(isMine ? Color.spPrimary : Color.spSurface)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                Text(message.sentAt.dateValue(), format: .dateTime.hour().minute())
                    .font(.caption2)
                    .foregroundStyle(Color.spTextSecondary.opacity(0.7))
            }
            if !isMine { Spacer(minLength: 40) }
        }
    }
}

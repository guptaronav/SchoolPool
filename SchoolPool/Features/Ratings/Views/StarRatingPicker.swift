import SwiftUI

struct StarRatingPicker: View {
    @Binding var rating: Int
    var size: CGFloat = 32

    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: size))
                    .foregroundStyle(star <= rating ? Color.spDroplet : Color.spTextSecondary.opacity(0.4))
                    .onTapGesture { rating = star }
                    .accessibilityLabel("\(star) star\(star == 1 ? "" : "s")")
            }
        }
    }
}

#if DEBUG
#Preview {
    StatefulPreviewWrapper(3) { StarRatingPicker(rating: $0) }
        .padding()
}

private struct StatefulPreviewWrapper<Value>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> StarRatingPicker
    init(_ initial: Value, content: @escaping (Binding<Value>) -> StarRatingPicker) {
        _value = State(initialValue: initial)
        self.content = content
    }
    var body: some View { content($value) }
}
#endif

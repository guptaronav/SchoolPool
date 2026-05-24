import SwiftUI

struct AvatarView: View {
    let urlString: String?
    let initials: String
    var size: CGFloat = 56

    var body: some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image): image.resizable().scaledToFill()
                    default: fallback
                    }
                }
            } else {
                fallback
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var fallback: some View {
        ZStack {
            Circle().fill(Color.spPrimary.opacity(0.15))
            Text(initials)
                .font(.system(size: size * 0.38, weight: .bold))
                .foregroundStyle(Color.spPrimary)
        }
    }
}

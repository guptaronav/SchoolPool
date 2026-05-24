import SwiftUI

struct SPButton: View {
    enum Style { case primary, secondary, danger }

    let title: String
    var style: Style = .primary
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(0.85)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, minHeight: 52)
            .foregroundStyle(foreground)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(isLoading)
    }

    private var background: Color {
        switch style {
        case .primary:   return .spPrimary
        case .secondary: return .spSurface
        case .danger:    return .spDanger
        }
    }

    private var foreground: Color {
        style == .secondary ? .spPrimary : .white
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        SPButton(title: "Join Carpool", action: {})
        SPButton(title: "Secondary", style: .secondary, action: {})
        SPButton(title: "Loading...", isLoading: true, action: {})
        SPButton(title: "Danger", style: .danger, action: {})
    }
    .padding()
    .background(Color.spBackground)
}
#endif

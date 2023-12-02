import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    @Environment(\.colorScheme) var colorScheme

    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(colorScheme == .dark ? .black : .white) // ダークモードでは黒、それ以外では白
            .padding()
            .background(Color.primary)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

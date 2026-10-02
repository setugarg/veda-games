import SwiftUI

/// Soft pastel palette. Nothing loud or neon.
enum Palette {
    static let cream = Color(hex: 0xFFF8EF)
    static let ink = Color(hex: 0x4B3F5C)
    static let inkSoft = Color(hex: 0x7D7290)

    static let peach = Color(hex: 0xFFE2CF)
    static let mint = Color(hex: 0xD5F0DF)
    static let lavender = Color(hex: 0xE3DBF6)
    static let sky = Color(hex: 0xD6E9F8)
    static let butter = Color(hex: 0xFFF1C7)
    static let rose = Color(hex: 0xF9DCE3)
    static let sage = Color(hex: 0xE2ECD2)

    static let peachDeep = Color(hex: 0xF2B196)
    static let mintDeep = Color(hex: 0x8FCFAA)
    static let lavenderDeep = Color(hex: 0xAE9FDC)
    static let skyDeep = Color(hex: 0x8FBDE2)
    static let butterDeep = Color(hex: 0xEDCC74)
    static let roseDeep = Color(hex: 0xE7A3B5)
    static let sageDeep = Color(hex: 0xA9C48A)

    static let soft: [Color] = [peach, mint, lavender, sky, butter, rose, sage]
    static let deep: [Color] = [peachDeep, mintDeep, lavenderDeep, skyDeep, butterDeep, roseDeep, sageDeep]

    static func soft(_ index: Int) -> Color { soft[abs(index) % soft.count] }
    static func deep(_ index: Int) -> Color { deep[abs(index) % deep.count] }

    /// A stable pastel for a string id, so a dish keeps its colour everywhere.
    static func tint(for id: String) -> Int {
        id.unicodeScalars.reduce(0) { ($0 &* 31 &+ Int($1.value)) & 0xFFFF }
    }

    static let skinTones: [Color] = [Color(hex: 0xF6D7BF), Color(hex: 0xE5B48F), Color(hex: 0xC68B62), Color(hex: 0x8D5A3B)]
    static let hairColors: [Color] = [Color(hex: 0x3D2C2E), Color(hex: 0x6B4A3A), Color(hex: 0xA8754B), Color(hex: 0x2B2A33)]
    static let outfits: [Color] = [Color(hex: 0xA9C7EC), Color(hex: 0xF4B6C2), Color(hex: 0xB5DFC1), Color(hex: 0xF7D58B), Color(hex: 0xC9B8EE)]
}

extension Color {
    init(hex: UInt32) {
        self.init(red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255)
    }
}

extension Font {
    static func kid(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
        .system(size: size, weight: weight, design: .rounded)
    }
}

/// A soft, puffy card.
struct PuffyCard: ViewModifier {
    var color: Color = .white
    var radius: CGFloat = 24

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(color)
                    .shadow(color: Palette.ink.opacity(0.08), radius: 10, y: 5)
            )
    }
}

extension View {
    func puffyCard(_ color: Color = .white, radius: CGFloat = 24) -> some View {
        modifier(PuffyCard(color: color, radius: radius))
    }
}

/// Big, squishy, kid-friendly button.
struct SquishyButtonStyle: ButtonStyle {
    var color: Color = Palette.mintDeep
    var textColor: Color = .white

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.kid(20))
            .foregroundStyle(textColor)
            .padding(.horizontal, 26)
            .padding(.vertical, 14)
            .background(
                Capsule(style: .continuous)
                    .fill(color)
                    .shadow(color: color.opacity(0.5), radius: configuration.isPressed ? 2 : 8,
                            y: configuration.isPressed ? 1 : 5)
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Gentle press-to-shrink for tappable cards.
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

/// Soft floating blobs behind screens.
struct PastelBackground: View {
    var tint: Int = 0
    @State private var drift = false

    var body: some View {
        ZStack {
            Palette.cream
            Circle().fill(Palette.soft(tint)).frame(width: 340).blur(radius: 30)
                .offset(x: drift ? -120 : -90, y: drift ? -260 : -230)
            Circle().fill(Palette.soft(tint + 2)).frame(width: 300).blur(radius: 30)
                .offset(x: drift ? 140 : 110, y: drift ? 120 : 150)
            Circle().fill(Palette.soft(tint + 4)).frame(width: 240).blur(radius: 30)
                .offset(x: drift ? -100 : -130, y: drift ? 360 : 330)
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 7).repeatForever(autoreverses: true)) { drift = true }
        }
    }
}

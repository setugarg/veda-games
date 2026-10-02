import SwiftUI

/// Tiffy, the talking steel tiffin box from Dadi's kitchen.
struct TiffyView: View {
    var size: CGFloat = 80
    var cheerful: Bool = true

    @State private var bob = false

    private let steel = Color(hex: 0xDCE0EA)
    private let steelEdge = Color(hex: 0xB9BFD0)

    var body: some View {
        let s = size
        VStack(spacing: s * 0.02) {
            // Handle
            Capsule()
                .stroke(steelEdge, lineWidth: s * 0.06)
                .frame(width: s * 0.5, height: s * 0.3)
                .offset(y: s * 0.1)
                .clipped()
            tier(s, height: s * 0.24)
            tier(s, height: s * 0.32)
                .overlay(face(s))
            tier(s, height: s * 0.24)
        }
        .frame(width: s, height: s * 1.2)
        .rotationEffect(.degrees(bob ? 3 : -3))
        .offset(y: bob ? -3 : 3)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true)) { bob = true }
        }
        .accessibilityLabel("Tiffy the tiffin box")
    }

    private func tier(_ s: CGFloat, height: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: s * 0.1, style: .continuous)
            .fill(LinearGradient(colors: [.white, steel], startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: s * 0.1, style: .continuous)
                    .stroke(steelEdge, lineWidth: s * 0.025)
            )
            .frame(width: s * 0.82, height: height)
    }

    private func face(_ s: CGFloat) -> some View {
        ZStack {
            HStack(spacing: s * 0.18) {
                Circle().fill(Palette.ink).frame(width: s * 0.07)
                Circle().fill(Palette.ink).frame(width: s * 0.07)
            }
            .offset(y: -s * 0.03)
            MouthShape(curve: cheerful ? 0.9 : -0.3)
                .stroke(Palette.ink, style: StrokeStyle(lineWidth: s * 0.03, lineCap: .round))
                .frame(width: s * 0.14, height: s * 0.05)
                .offset(y: s * 0.06)
            HStack(spacing: s * 0.36) {
                Circle().fill(Palette.roseDeep.opacity(0.5)).frame(width: s * 0.07)
                Circle().fill(Palette.roseDeep.opacity(0.5)).frame(width: s * 0.07)
            }
            .offset(y: s * 0.04)
        }
    }
}

/// Tiffy with a speech bubble and a read-aloud button.
struct TiffySays: View {
    let text: String
    var size: CGFloat = 64
    var autoSpeak: Bool = false
    var showTiffy: Bool = true

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if showTiffy { TiffyView(size: size) }
            HStack(alignment: .top, spacing: 8) {
                Text(text)
                    .font(.kid(16, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SpeakButton(text: text)
            }
            .padding(14)
            .puffyCard(.white, radius: 20)
        }
        .task(id: text) {
            if autoSpeak { Narrator.shared.speak(text) }
        }
    }
}

#Preview {
    TiffySays(text: "Hello! I'm Tiffy. Let's find the food that helps!")
        .padding()
        .background(Palette.cream)
}

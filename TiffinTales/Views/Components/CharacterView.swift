import SwiftUI

/// The child's character, drawn entirely with shapes so it animates smoothly
/// and can be customised (skin tone, hair, outfit) without image assets.
struct CharacterView: View {
    var mood: Mood
    var avatar: AvatarStyle
    var size: CGFloat = 180

    @State private var breathe = false
    @State private var blink = false
    @State private var floatBadge = false

    private var skin: Color { Palette.skinTones[avatar.skinTone % Palette.skinTones.count] }
    private var hair: Color { Palette.hairColors[avatar.hairColor % Palette.hairColors.count] }
    private var outfit: Color { Palette.outfits[avatar.outfitColor % Palette.outfits.count] }

    var body: some View {
        let s = size
        ZStack {
            // Shadow on the ground
            Ellipse()
                .fill(Palette.ink.opacity(0.08))
                .frame(width: s * 0.6, height: s * 0.08)
                .offset(y: s * 0.62)

            torso(s)
                .offset(y: s * 0.32)

            head(s)
                .offset(y: -s * 0.12)
                .rotationEffect(.degrees(headTilt), anchor: .bottom)

            moodBadge(s)
        }
        .frame(width: s, height: s * 1.35)
        .scaleEffect(x: 1, y: breathe ? 1.015 : 0.99, anchor: .bottom)
        .offset(y: mood == .excited && breathe ? -s * 0.05 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: mood)
        .onAppear {
            withAnimation(.easeInOut(duration: mood == .excited ? 0.45 : 1.6).repeatForever(autoreverses: true)) {
                breathe = true
            }
            withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                floatBadge = true
            }
        }
        .task(id: mood) { await blinkLoop() }
        .accessibilityElement()
        .accessibilityLabel("Your character looks \(mood.rawValue)")
    }

    private var headTilt: Double {
        switch mood {
        case .sleepy: return -8
        case .tired: return -4
        case .sick: return 5
        default: return 0
        }
    }

    // MARK: Parts

    private func torso(_ s: CGFloat) -> some View {
        ZStack {
            // Arms
            let armUp = mood == .excited
            Capsule().fill(skin)
                .frame(width: s * 0.11, height: s * 0.32)
                .offset(x: -s * 0.3, y: armUp ? -s * 0.12 : 0)
                .rotationEffect(.degrees(armUp ? 145 : 18), anchor: .top)
            Capsule().fill(skin)
                .frame(width: s * 0.11, height: s * 0.32)
                .offset(x: s * 0.3, y: armUp ? -s * 0.12 : 0)
                .rotationEffect(.degrees(armUp ? -145 : -18), anchor: .top)

            // Shirt
            RoundedRectangle(cornerRadius: s * 0.16, style: .continuous)
                .fill(outfit)
                .frame(width: s * 0.56, height: s * 0.42)
            // Little pocket
            RoundedRectangle(cornerRadius: s * 0.03)
                .fill(.white.opacity(0.45))
                .frame(width: s * 0.12, height: s * 0.09)
                .offset(x: s * 0.12, y: -s * 0.04)
        }
    }

    private func head(_ s: CGFloat) -> some View {
        let d = s * 0.62
        return ZStack {
            hairBack(d)
            Circle().fill(skin).frame(width: d, height: d)
            // Ears
            Circle().fill(skin).frame(width: d * 0.18).offset(x: -d * 0.5, y: d * 0.05)
            Circle().fill(skin).frame(width: d * 0.18).offset(x: d * 0.5, y: d * 0.05)
            hairFront(d)
            face(d)
        }
    }

    @ViewBuilder
    private func hairBack(_ d: CGFloat) -> some View {
        switch avatar.hairStyle % 4 {
        case 1: // Bun
            Circle().fill(hair).frame(width: d * 0.38).offset(y: -d * 0.55)
        case 2: // Curly
            ForEach(0..<7, id: \.self) { i in
                let angle = Double(i) / 6 * .pi + .pi
                Circle().fill(hair).frame(width: d * 0.34)
                    .offset(x: cos(angle) * d * 0.45, y: sin(angle) * d * 0.42)
            }
        case 3: // Two plaits
            Capsule().fill(hair).frame(width: d * 0.2, height: d * 0.55).offset(x: -d * 0.52, y: d * 0.2)
            Capsule().fill(hair).frame(width: d * 0.2, height: d * 0.55).offset(x: d * 0.52, y: d * 0.2)
        default:
            EmptyView()
        }
    }

    private func hairFront(_ d: CGFloat) -> some View {
        // A soft fringe cap over the top of the head.
        Circle()
            .trim(from: 0.5, to: 1)
            .fill(hair)
            .frame(width: d * 1.04, height: d * 1.04)
            .scaleEffect(x: 1, y: 0.82, anchor: .center)
            .offset(y: -d * 0.04)
            .mask(
                Circle().frame(width: d * 1.04)
            )
            .overlay(
                // Little tuft
                Capsule().fill(hair)
                    .frame(width: d * 0.1, height: d * 0.2)
                    .rotationEffect(.degrees(25))
                    .offset(x: d * 0.05, y: -d * 0.55)
            )
    }

    private func face(_ d: CGFloat) -> some View {
        ZStack {
            // Cheeks
            Circle().fill(Palette.roseDeep.opacity(mood == .sick ? 0.15 : 0.45))
                .frame(width: d * 0.16).offset(x: -d * 0.27, y: d * 0.14)
            Circle().fill(Palette.roseDeep.opacity(mood == .sick ? 0.15 : 0.45))
                .frame(width: d * 0.16).offset(x: d * 0.27, y: d * 0.14)

            eyes(d)
            brows(d)

            MouthShape(curve: mouthCurve)
                .stroke(Palette.ink, style: StrokeStyle(lineWidth: d * 0.035, lineCap: .round))
                .frame(width: d * mouthWidth, height: d * 0.12)
                .offset(y: d * 0.22)
        }
    }

    @ViewBuilder
    private func eyes(_ d: CGFloat) -> some View {
        let spacing = d * 0.18
        switch mood {
        case .sleepy:
            ForEach([-1.0, 1.0], id: \.self) { side in
                Capsule().fill(Palette.ink)
                    .frame(width: d * 0.12, height: d * 0.03)
                    .offset(x: side * spacing, y: d * 0.02)
            }
        case .happy, .excited:
            ForEach([-1.0, 1.0], id: \.self) { side in
                EyeArc()
                    .stroke(Palette.ink, style: StrokeStyle(lineWidth: d * 0.035, lineCap: .round))
                    .frame(width: d * 0.12, height: d * 0.07)
                    .offset(x: side * spacing, y: -d * 0.01)
                    .scaleEffect(y: blink ? 0.2 : 1)
            }
        default:
            ForEach([-1.0, 1.0], id: \.self) { side in
                ZStack {
                    Ellipse().fill(Palette.ink)
                        .frame(width: d * 0.1, height: d * (mood == .sick || mood == .tired ? 0.08 : 0.13))
                    Circle().fill(.white).frame(width: d * 0.035).offset(x: d * 0.02, y: -d * 0.025)
                }
                .scaleEffect(y: blink ? 0.1 : 1)
                .offset(x: side * spacing, y: 0)
            }
        }
    }

    @ViewBuilder
    private func brows(_ d: CGFloat) -> some View {
        if mood == .worried || mood == .sick {
            ForEach([-1.0, 1.0], id: \.self) { side in
                Capsule().fill(hair.opacity(0.85))
                    .frame(width: d * 0.13, height: d * 0.03)
                    .rotationEffect(.degrees(side * -14))
                    .offset(x: side * d * 0.19, y: -d * 0.13)
            }
        }
    }

    private var mouthCurve: CGFloat {
        switch mood {
        case .happy: return 0.8
        case .excited: return 1.0
        case .sleepy: return 0.1
        case .tired: return -0.2
        case .worried: return -0.45
        case .sick: return -0.6
        }
    }

    private var mouthWidth: CGFloat {
        switch mood {
        case .excited: return 0.32
        case .sleepy: return 0.1
        default: return 0.22
        }
    }

    @ViewBuilder
    private func moodBadge(_ s: CGFloat) -> some View {
        if let badge = badge {
            Text(badge)
                .font(.system(size: s * 0.18))
                .offset(x: s * 0.36, y: -s * 0.48 + (floatBadge ? -6 : 4))
                .transition(.scale.combined(with: .opacity))
        }
    }

    private var badge: String? {
        switch mood {
        case .sleepy: return "💤"
        case .sick: return "🌡️"
        case .tired: return "💦"
        case .worried: return "❓"
        case .excited: return "✨"
        case .happy: return nil
        }
    }

    private func blinkLoop() async {
        while !Task.isCancelled {
            try? await Task.sleep(nanoseconds: UInt64.random(in: 2_200_000_000...4_200_000_000))
            withAnimation(.easeInOut(duration: 0.08)) { blink = true }
            try? await Task.sleep(nanoseconds: 140_000_000)
            withAnimation(.easeInOut(duration: 0.08)) { blink = false }
        }
    }
}

/// A smile (positive curve) or frown (negative curve) that animates smoothly between moods.
struct MouthShape: Shape {
    var curve: CGFloat

    var animatableData: CGFloat {
        get { curve }
        set { curve = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let midY = rect.midY - curve * rect.height * 0.3
        path.move(to: CGPoint(x: rect.minX, y: midY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: midY),
                          control: CGPoint(x: rect.midX, y: midY + curve * rect.height * 1.4))
        return path
    }
}

/// Happy closed eyes: ^ ^
struct EyeArc: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addQuadCurve(to: CGPoint(x: rect.maxX, y: rect.maxY),
                          control: CGPoint(x: rect.midX, y: rect.minY - rect.height * 0.6))
        return path
    }
}

#Preview {
    HStack {
        CharacterView(mood: .sleepy, avatar: AvatarStyle(), size: 120)
        CharacterView(mood: .excited, avatar: AvatarStyle(skinTone: 2, hairStyle: 2), size: 120)
        CharacterView(mood: .sick, avatar: AvatarStyle(skinTone: 3, hairStyle: 3), size: 120)
    }
    .padding()
    .background(Palette.cream)
}

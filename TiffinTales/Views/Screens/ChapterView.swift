import SwiftUI

/// A winding path of bite-sized missions.
struct ChapterView: View {
    let chapter: Chapter
    @Environment(GameStore.self) private var store
    @Environment(Router.self) private var router
    @State private var appeared = false

    var body: some View {
        ZStack {
            PastelBackground(tint: chapter.tint)
            ScrollView {
                VStack(spacing: 18) {
                    VStack(spacing: 6) {
                        Text(chapter.emoji).font(.system(size: 56))
                        Text("Chapter \(chapter.number)")
                            .font(.kid(14, weight: .heavy))
                            .foregroundStyle(Palette.inkSoft)
                        Text(chapter.title)
                            .font(.kid(28, weight: .heavy))
                            .foregroundStyle(Palette.ink)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    TiffySays(text: chapter.intro.personalized(store.name, elder: store.elder), size: 56)

                    VStack(spacing: 0) {
                        ForEach(Array(chapter.missions.enumerated()), id: \.element.id) { index, mission in
                            missionNode(mission, index: index)
                                .offset(x: index.isMultiple(of: 2) ? -50 : 50)
                                .scaleEffect(appeared ? 1 : 0.4)
                                .opacity(appeared ? 1 : 0)
                                .animation(.spring(response: 0.5, dampingFraction: 0.6).delay(Double(index) * 0.08), value: appeared)
                            if index < chapter.missions.count - 1 {
                                PathDots(leftToRight: index.isMultiple(of: 2))
                                    .frame(height: 36)
                            }
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { appeared = true }
    }

    private func missionNode(_ mission: Mission, index: Int) -> some View {
        let unlocked = store.progress.isUnlocked(mission)
        let stars = store.progress.stars[mission.id] ?? 0
        let isNext = store.progress.nextMission == mission

        return Button {
            Haptics.tap()
            router.play(mission)
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(unlocked ? Palette.soft(chapter.tint + index + 1) : Color.white.opacity(0.6))
                        .frame(width: 92, height: 92)
                        .overlay(Circle().stroke(isNext ? Palette.deep(chapter.tint) : .white, lineWidth: isNext ? 5 : 3))
                        .shadow(color: Palette.ink.opacity(0.1), radius: 8, y: 4)
                    if unlocked {
                        Text(mission.ailment?.emoji ?? mission.wisdomTopic?.emoji ?? mission.needs.first?.emoji ?? (mission.elderQuestion != nil ? "🎙️" : "⭐️"))
                            .font(.system(size: 40))
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(Palette.inkSoft.opacity(0.6))
                    }
                }
                .modifier(PulseIf(active: isNext))
                Text(mission.title)
                    .font(.kid(14, weight: .heavy))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                    .frame(width: 150)
                if let badge = badge(for: mission) {
                    Text(badge)
                        .font(.kid(10, weight: .heavy))
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.horizontal, 8).padding(.vertical, 2)
                        .background(Capsule().fill(Palette.sage))
                }
                StarsView(count: stars, size: 14)
            }
        }
        .buttonStyle(PressableStyle())
        .disabled(!unlocked)
    }
}

private func badge(for mission: Mission) -> String? {
    if mission.ailment != nil { return "Home remedy" }
    if mission.wisdomTopic != nil { return "Grandma wisdom" }
    if mission.elderQuestion != nil { return "Ask an elder" }
    return nil
}

private struct PathDots: View {
    let leftToRight: Bool

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<4, id: \.self) { _ in
                Circle().fill(Palette.inkSoft.opacity(0.25)).frame(width: 8, height: 8)
            }
        }
        .rotationEffect(.degrees(leftToRight ? 25 : -25))
    }
}

private struct PulseIf: ViewModifier {
    let active: Bool
    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(active && pulse ? 1.07 : 1)
            .onAppear {
                guard active else { return }
                withAnimation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true)) { pulse = true }
            }
    }
}

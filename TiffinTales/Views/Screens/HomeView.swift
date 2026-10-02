import SwiftUI

struct HomeView: View {
    @Environment(GameStore.self) private var store
    @Environment(Router.self) private var router
    @State private var showGate = false
    @State private var showSettings = false

    private var greeting: String {
        if let next = store.progress.nextMission, let chapter = store.chapter(of: next) {
            return next == StoryContent.allMissions.first
                ? "Hi {name}! Our adventure is about to begin. Ready?".personalized(store.name)
                : "Welcome back, {name}! Chapter \(chapter.number) is waiting: \(chapter.title)!".personalized(store.name)
        }
        return "You finished the whole year, {name}! Replay any mission to earn more stars.".personalized(store.name)
    }

    var body: some View {
        ZStack {
            PastelBackground(tint: 0)
            ScrollView {
                VStack(spacing: 20) {
                    header
                    hero
                    if let next = store.progress.nextMission {
                        continueButton(next)
                    }
                    chapters
                    books
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
                .frame(maxWidth: 640)
                .frame(maxWidth: .infinity)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showGate) {
            GrownUpGate {
                showGate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showSettings = true }
            }
        }
        .sheet(isPresented: $showSettings) { ParentSettingsView() }
    }

    private var header: some View {
        HStack {
            Text("Tiffin Tales")
                .font(.kid(30, weight: .heavy))
                .foregroundStyle(Palette.ink)
            Spacer()
            HStack(spacing: 4) {
                Image(systemName: "star.fill").foregroundStyle(Palette.butterDeep)
                Text("\(store.progress.totalStars)").font(.kid(18))
            }
            .foregroundStyle(Palette.ink)
            .padding(.horizontal, 12).padding(.vertical, 8)
            .puffyCard(.white, radius: 16)
            Button { showGate = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Palette.inkSoft)
                    .frame(width: 42, height: 42)
                    .puffyCard(.white, radius: 16)
            }
            .accessibilityLabel("Grown-ups")
        }
        .padding(.top, 8)
    }

    private var hero: some View {
        VStack(spacing: 8) {
            HStack(alignment: .bottom, spacing: -6) {
                CharacterView(mood: .happy, avatar: store.settings.avatar, size: 140)
                TiffyView(size: 70).offset(y: -8)
            }
            TiffySays(text: greeting, showTiffy: false)
        }
    }

    private func continueButton(_ mission: Mission) -> some View {
        Button {
            Haptics.tap()
            router.play(mission)
        } label: {
            HStack(spacing: 14) {
                Text(mission.scene).font(.system(size: 34))
                VStack(alignment: .leading, spacing: 2) {
                    Text(mission == StoryContent.allMissions.first ? "Start the story" : "Continue")
                        .font(.kid(14, weight: .heavy))
                        .foregroundStyle(.white.opacity(0.9))
                    Text(mission.title)
                        .font(.kid(20, weight: .heavy))
                        .foregroundStyle(.white)
                }
                Spacer()
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(.white)
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LinearGradient(colors: [Palette.mintDeep, Palette.skyDeep], startPoint: .leading, endPoint: .trailing))
                    .shadow(color: Palette.mintDeep.opacity(0.4), radius: 10, y: 6)
            )
        }
        .buttonStyle(PressableStyle())
    }

    private var chapters: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("The Story")
                .font(.kid(22, weight: .heavy))
                .foregroundStyle(Palette.ink)
            ForEach(StoryContent.chapters) { chapter in
                let unlocked = chapter.missions.first.map(store.progress.isUnlocked) ?? false
                let earned = chapter.missions.reduce(0) { $0 + (store.progress.stars[$1.id] ?? 0) }
                Button {
                    Haptics.tap()
                    router.path.append(.chapter(chapter))
                } label: {
                    HStack(spacing: 14) {
                        Text(chapter.emoji)
                            .font(.system(size: 34))
                            .frame(width: 60, height: 60)
                            .background(Circle().fill(.white.opacity(0.7)))
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Chapter \(chapter.number)")
                                .font(.kid(12, weight: .heavy))
                                .foregroundStyle(Palette.inkSoft)
                            Text(chapter.title)
                                .font(.kid(18, weight: .heavy))
                                .foregroundStyle(Palette.ink)
                            HStack(spacing: 4) {
                                Image(systemName: "star.fill").font(.system(size: 11))
                                    .foregroundStyle(Palette.butterDeep)
                                Text("\(earned) / \(chapter.missions.count * 3)")
                                    .font(.kid(12, weight: .bold))
                                    .foregroundStyle(Palette.inkSoft)
                            }
                        }
                        Spacer()
                        Image(systemName: unlocked ? "chevron.right" : "lock.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(Palette.inkSoft)
                    }
                    .padding(14)
                    .puffyCard(Palette.soft(chapter.tint))
                    .opacity(unlocked ? 1 : 0.55)
                }
                .buttonStyle(PressableStyle())
                .disabled(!unlocked)
            }
        }
    }

    private var books: some View {
        HStack(spacing: 12) {
            bookTile("Nutrient Book", emoji: "📖",
                     detail: "\(store.progress.discoveredNutrients.count)/\(Nutrient.allCases.count)", tint: 3) {
                router.path.append(.nutrientBook)
            }
            bookTile("Remedy Book", emoji: "🌿",
                     detail: "\(store.progress.learnedRemedies.count) learned", tint: 6) {
                router.path.append(.remedyBook)
            }
            bookTile("My Pantry", emoji: "🧺",
                     detail: "\(store.pantry.foods.count) dishes", tint: 0) {
                router.path.append(.pantry)
            }
        }
    }

    private func bookTile(_ title: String, emoji: String, detail: String, tint: Int, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.tap()
            action()
        } label: {
            VStack(spacing: 6) {
                Text(emoji).font(.system(size: 34))
                Text(title).font(.kid(14, weight: .heavy)).foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                Text(detail).font(.kid(11, weight: .bold)).foregroundStyle(Palette.inkSoft)
            }
            .frame(maxWidth: .infinity, minHeight: 120)
            .puffyCard(Palette.soft(tint))
        }
        .buttonStyle(PressableStyle())
    }
}

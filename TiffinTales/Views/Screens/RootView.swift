import SwiftUI

struct RootView: View {
    @Environment(GameStore.self) private var store
    @Environment(Router.self) private var router

    private var screenshotOverride: Bool {
        #if DEBUG
        return ScreenshotMode.overridesRoot
        #else
        return false
        #endif
    }

    var body: some View {
        @Bindable var router = router
        Group {
            if screenshotOverride {
                #if DEBUG
                ScreenshotMode.overrideRoot(store: store)
                #endif
            } else if store.settings.hasCompletedSetup {
                NavigationStack(path: $router.path) {
                    HomeView()
                        .navigationDestination(for: Route.self) { route in
                            switch route {
                            case .chapter(let chapter): ChapterView(chapter: chapter)
                            case .mission(let mission): MissionView(mission: mission).id(mission.id)
                            case .nutrientBook: NutrientBookView()
                            case .remedyBook: RemedyBookView()
                            case .wisdomBook: WisdomBookView()
                            case .pantry: PantryView()
                            }
                        }
                }
            } else {
                WelcomeView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: store.settings.hasCompletedSetup)
    }
}

/// First launch: meet Tiffy, then a grown-up stocks the pantry (or uses the starter one).
struct WelcomeView: View {
    @Environment(GameStore.self) private var store
    @State private var showGate = false
    @State private var showSettings = false
    @State private var appear = false

    var body: some View {
        ZStack {
            PastelBackground(tint: 2)
            ScrollView {
                VStack(spacing: 22) {
                    Text("Tiffin Tales")
                        .font(.kid(44, weight: .heavy))
                        .foregroundStyle(Palette.ink)
                        .padding(.top, 40)
                    Text("Healthy home food adventures")
                        .font(.kid(18, weight: .semibold))
                        .foregroundStyle(Palette.inkSoft)

                    HStack(alignment: .bottom, spacing: 0) {
                        CharacterView(mood: .happy, avatar: store.settings.avatar, size: 150)
                        TiffyView(size: 90)
                            .offset(y: -10)
                    }
                    .scaleEffect(appear ? 1 : 0.6)
                    .opacity(appear ? 1 : 0)

                    TiffySays(text: StoryContent.prologue.personalized(store.name, elder: store.elder), showTiffy: false)
                        .padding(.horizontal)

                    VStack(spacing: 14) {
                        Button {
                            showGate = true
                        } label: {
                            Label("Grown-up: fill the pantry", systemImage: "basket.fill")
                        }
                        .buttonStyle(SquishyButtonStyle(color: Palette.lavenderDeep))

                        Button("Start with a starter pantry") {
                            store.settings.hasCompletedSetup = true
                            store.saveSettings()
                        }
                        .buttonStyle(SquishyButtonStyle(color: Palette.mintDeep))
                    }
                    .padding(.bottom, 40)
                }
                .frame(maxWidth: 560)
                .frame(maxWidth: .infinity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.6)) { appear = true }
        }
        .sheet(isPresented: $showGate) {
            GrownUpGate {
                showGate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { showSettings = true }
            }
        }
        .sheet(isPresented: $showSettings, onDismiss: {
            store.settings.hasCompletedSetup = true
            store.saveSettings()
        }) {
            ParentSettingsView()
        }
    }
}

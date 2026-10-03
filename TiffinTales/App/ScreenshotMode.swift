import SwiftUI

#if DEBUG
/// Debug-only: opens the app straight onto one screen so CI can screenshot it.
/// Launch with `-screen <name>`, e.g. `xcrun simctl launch booted com.vedagames.tiffintales -screen home`.
/// Nothing is saved while in this mode.
enum ScreenshotMode {
    static let screen = UserDefaults.standard.string(forKey: "screen")
    static var isActive: Bool { screen != nil }

    /// Mission screens open past the intro, on the playing board.
    static var startsPlaying: Bool { screen?.hasPrefix("play-") == true }

    static let screens = [
        "welcome", "home", "chapter", "intro", "play-meal", "play-remedy", "play-wisdom", "play-elder",
        "wisdom-book", "nutrient-book", "remedy-book", "pantry", "settings", "family-dish", "family-remedy",
    ]

    static func prepare(store: GameStore, router: Router) {
        guard let screen else { return }
        store.settings.hasCompletedSetup = screen != "welcome"

        // Pretend the first chapter is done, so maps and books have something in them.
        let missions = StoryContent.allMissions
        for (index, mission) in missions.prefix(6).enumerated() {
            store.progress.stars[mission.id] = [3, 2, 3, 1, 3, 2][index]
        }
        store.progress.discoveredNutrients = [.carbs, .protein, .iron, .vitaminC, .calcium, .fiber, .probiotics]
        store.progress.discoveredCombos = ["complete-protein", "iron-vitc"]
        if let first = Catalog.wisdom(for: .breakfast, settings: store.settings, using: &rng) {
            store.progress.learnedWisdom = [first.id]
        }
        store.familyTips = [FamilyTip(author: store.elder, kind: .pairing, title: "Always a squeeze of lemon on dal",
                                      text: "It helps the iron work, and it tastes better too!")]

        func mission(_ id: String) -> Mission { missions.first { $0.id == id }! }
        switch screen {
        case "chapter": router.path = [.chapter(StoryContent.chapters[0])]
        case "intro", "play-meal": router.path = [.mission(mission("c1m1"))]
        case "play-remedy": router.path = [.mission(mission("c1m4"))]
        case "play-wisdom": router.path = [.mission(mission("c1w1"))]
        case "play-elder": router.path = [.mission(mission("c3e1"))]
        case "wisdom-book": router.path = [.wisdomBook]
        case "nutrient-book": router.path = [.nutrientBook]
        case "remedy-book": router.path = [.remedyBook]
        case "pantry": router.path = [.pantry]
        default: break
        }
    }

    private static var rng = SystemRandomNumberGenerator()

    /// Screens that are normally sheets, shown full-screen instead.
    @ViewBuilder
    static func overrideRoot(store: GameStore) -> some View {
        switch screen {
        case "settings":
            ParentSettingsView()
        case "family-dish":
            FoodEditorView(food: {
                var food = DishTemplate.all[1].makeFood()
                food.name = "\(store.elder)'s Dal Chawal"
                food.blurb = "Yellow dal with a lemon squeeze, on soft rice."
                return food
            }(), isNew: true)
        case "family-remedy":
            RemedyEditorView(remedy: {
                var remedy = RemedyTemplate.all[0].makeRemedy(author: store.elder)
                remedy.name = "\(store.elder)'s Ginger Kadha"
                remedy.howItHelps = "Ginger and tulsi soothe a scratchy throat."
                return remedy
            }(), isNew: true)
        default:
            EmptyView()
        }
    }

    static var overridesRoot: Bool { ["settings", "family-dish", "family-remedy"].contains(screen ?? "") }
}
#endif

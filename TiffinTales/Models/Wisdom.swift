import Foundation

/// The kinds of kitchen knowledge grandparents pass down.
enum WisdomKind: String, CaseIterable, Codable, Identifiable {
    case pairing, preparation, season, afterMeal, balance, timing, remedy, story

    var id: String { rawValue }

    var name: String {
        switch self {
        case .pairing: return "What Goes With What"
        case .preparation: return "Kitchen Magic"
        case .season: return "Eat With the Seasons"
        case .afterMeal: return "After the Meal"
        case .balance: return "A Balanced Plate"
        case .timing: return "When to Eat"
        case .remedy: return "Home Remedies"
        case .story: return "Family Stories"
        }
    }

    var emoji: String {
        switch self {
        case .pairing: return "🤝"
        case .preparation: return "🪄"
        case .season: return "🌦️"
        case .afterMeal: return "🌿"
        case .balance: return "🍽️"
        case .timing: return "⏰"
        case .remedy: return "🫖"
        case .story: return "📜"
        }
    }
}

/// How strongly modern science backs a tradition. Kids learn that both
/// grandma's experience and scientists' experiments are ways of knowing.
enum Evidence: String, Codable {
    case strong, some, tradition

    var label: String {
        switch self {
        case .strong: return "Science agrees!"
        case .some: return "Science partly agrees"
        case .tradition: return "Family tradition: scientists are still studying it"
        }
    }

    var emoji: String {
        switch self {
        case .strong: return "🔬✅"
        case .some: return "🔬👍"
        case .tradition: return "👵🏽💛"
        }
    }
}

/// A question a Wisdom mission asks. Each topic has a shared ("universal")
/// card plus culture-specific versions; the family's packages pick which one appears.
enum WisdomTopic: String, CaseIterable, Codable {
    case grainPartner, ironHelper, haldiPepper, beansGas, soaking, sprouting, fermenting
    case fatForVitaminA, summerCooler, winterWarmer, afterMeal, balancedPlate, breakfast, afterDinnerWalk

    var emoji: String {
        switch self {
        case .grainPartner: return "🍛"
        case .ironHelper: return "🍋"
        case .haldiPepper: return "🟠"
        case .beansGas: return "🫘"
        case .soaking: return "💧"
        case .sprouting: return "🌱"
        case .fermenting: return "🫧"
        case .fatForVitaminA: return "🥕"
        case .summerCooler: return "☀️"
        case .winterWarmer: return "❄️"
        case .afterMeal: return "🌿"
        case .balancedPlate: return "🍽️"
        case .breakfast: return "🌅"
        case .afterDinnerWalk: return "🚶"
        }
    }
}

struct WisdomChoice: Hashable {
    let emoji: String
    let name: String
    /// Why this is (or isn't) the answer. Shown after a pick.
    let note: String

    init(_ emoji: String, _ name: String, _ note: String = "") {
        self.emoji = emoji
        self.name = name
        self.note = note
    }
}

/// One piece of grandparent food knowledge, written as a little quiz.
struct Wisdom: Identifiable, Hashable {
    let id: String
    let topic: WisdomTopic
    let kind: WisdomKind
    let title: String
    let emoji: String
    /// Package ids this belongs to. Empty means it's shared by many homes.
    let cultures: Set<String>
    /// "Rajasthani homes", "Homes across India", "Mexican homes"…
    let origin: String
    /// The question. `{name}` and `{elder}` are filled in.
    let question: String
    let answer: WisdomChoice
    let distractors: [WisdomChoice]
    let grandmaSays: String
    let scienceSays: String
    let evidence: Evidence
    /// A real saying from the tradition, if there is a well-known one.
    let saying: String?
    let allergens: Set<Allergen>
    let diet: Diet

    init(_ id: String, _ topic: WisdomTopic, _ kind: WisdomKind, _ title: String, _ emoji: String,
         cultures: Set<String> = [], origin: String,
         question: String, answer: WisdomChoice, distractors: [WisdomChoice],
         grandma: String, science: String, evidence: Evidence,
         saying: String? = nil, allergens: Set<Allergen> = [], diet: Diet = .vegan) {
        self.id = id
        self.topic = topic
        self.kind = kind
        self.title = title
        self.emoji = emoji
        self.cultures = cultures
        self.origin = origin
        self.question = question
        self.answer = answer
        self.distractors = distractors
        self.grandmaSays = grandma
        self.scienceSays = science
        self.evidence = evidence
        self.saying = saying
        self.allergens = allergens
        self.diet = diet
    }

    var isUniversal: Bool { cultures.isEmpty }

    func isAllowed(for diet: Diet, avoiding allergies: Set<Allergen>) -> Bool {
        self.diet <= diet && allergens.isDisjoint(with: allergies)
    }

    static func == (lhs: Wisdom, rhs: Wisdom) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// A "Grandma Combo": foods that work better together, spotted on the child's plate.
struct Combo: Identifiable, Hashable {
    enum Rule: Hashable {
        /// Every listed nutrient must be somewhere on the plate.
        case nutrients([Nutrient])
        /// A legume dish together with a grain dish (can be one dish like dal-chawal).
        case legumeAndGrain
    }

    let id: String
    let title: String
    let emoji: String
    let rule: Rule
    let explanation: String

    static func == (lhs: Combo, rhs: Combo) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

/// Knowledge a family adds themselves: a tip, a remedy, or a recorded story.
struct FamilyTip: Codable, Identifiable, Equatable {
    var id = UUID()
    var author: String
    var kind: WisdomKind
    var title: String
    var text: String
    /// File name of a voice recording in the app's documents folder.
    var audioFile: String?
    var createdAt = Date()
}

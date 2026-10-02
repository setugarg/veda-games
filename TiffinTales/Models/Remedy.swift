import Foundation

/// Common, mild childhood troubles that home remedies can soothe.
enum Ailment: String, CaseIterable, Codable, Identifiable {
    case soreThroat, sniffles, cough, tummyAche, travelTummy, stuckTummy
    case toothache, mildHeadache, sneezyAllergy, itchyBite, tooHot, tiredMuscles, hiccups

    var id: String { rawValue }

    var name: String {
        switch self {
        case .soreThroat: return "Scratchy Throat"
        case .sniffles: return "Sniffly Nose"
        case .cough: return "Tickly Cough"
        case .tummyAche: return "Grumbly Tummy"
        case .travelTummy: return "Wobbly Travel Tummy"
        case .stuckTummy: return "Stuck Tummy"
        case .toothache: return "Achy Tooth"
        case .mildHeadache: return "Thumpy Head"
        case .sneezyAllergy: return "Sneezy Pollen Allergy"
        case .itchyBite: return "Itchy Mosquito Bite"
        case .tooHot: return "Too-Hot Day"
        case .tiredMuscles: return "Sore Legs"
        case .hiccups: return "Hiccups"
        }
    }

    var emoji: String {
        switch self {
        case .soreThroat: return "😣"
        case .sniffles: return "🤧"
        case .cough: return "😮‍💨"
        case .tummyAche: return "🤢"
        case .travelTummy: return "🚗"
        case .stuckTummy: return "😖"
        case .toothache: return "🦷"
        case .mildHeadache: return "🤕"
        case .sneezyAllergy: return "🌼"
        case .itchyBite: return "🦟"
        case .tooHot: return "🥵"
        case .tiredMuscles: return "🦵"
        case .hiccups: return "😲"
        }
    }

    /// What is happening in the body, in kid language.
    var whatsHappening: String {
        switch self {
        case .soreThroat: return "Tiny germs are tickling your throat, so it gets red and puffy."
        case .sniffles: return "Your nose makes extra mucus to wash germs away. That's why it drips!"
        case .cough: return "Coughing is your body's way of pushing out dust and germs from your chest."
        case .tummyAche: return "Sometimes food is hard to digest or makes gas bubbles, and your tummy grumbles."
        case .travelTummy: return "Your eyes and ears disagree about whether you're moving, and your tummy gets confused."
        case .stuckTummy: return "When we don't eat enough fiber or drink enough water, poop gets stuck."
        case .toothache: return "Sugar left on teeth feeds germs that make a tiny hole. The tooth's nerve says ouch!"
        case .mildHeadache: return "Not enough water, sleep or food can make your head feel thumpy."
        case .sneezyAllergy: return "Your body thinks tiny pollen dust is a germ and sneezes to blow it away."
        case .itchyBite: return "A mosquito left a little spit behind, and your skin swells and itches."
        case .tooHot: return "When it's very hot you sweat out water and salts, and you feel dizzy and droopy."
        case .tiredMuscles: return "After lots of running, muscles get tiny strains. Rest helps them grow stronger."
        case .hiccups: return "Your breathing muscle, the diaphragm, is doing little jumps!"
        }
    }

    /// Always shown so kids know when home care isn't enough.
    var grownUpNote: String {
        switch self {
        case .toothache: return "Tell a grown-up. If it keeps hurting, a dentist needs to take a look."
        case .sneezyAllergy: return "Tell a grown-up. Allergies can be serious; a doctor can help find what causes them."
        case .mildHeadache: return "Tell a grown-up. If your head hurts a lot or often, see a doctor."
        case .tooHot: return "Tell a grown-up right away and rest in the shade. Very hot days can be dangerous."
        default: return "Always tell a grown-up. If you don't feel better soon, visit a doctor."
        }
    }
}

/// A traditional home remedy from a particular culture.
struct Remedy: Identifiable, Hashable {
    let id: String
    let name: String
    let localName: String?
    let emoji: String
    let treats: Set<Ailment>
    /// The key ingredient and how it helps.
    let howItHelps: String
    /// Simple steps, made *with a grown-up*.
    let steps: [String]
    let caution: String?
    let diet: Diet
    let allergens: Set<Allergen>

    init(_ id: String,
         _ name: String,
         local: String? = nil,
         _ emoji: String,
         treats: Set<Ailment>,
         _ howItHelps: String,
         steps: [String],
         caution: String? = nil,
         diet: Diet = .vegetarian,
         allergens: Set<Allergen> = []) {
        self.id = id
        self.name = name
        self.localName = local
        self.emoji = emoji
        self.treats = treats
        self.howItHelps = howItHelps
        self.steps = steps
        self.caution = caution
        self.diet = diet
        self.allergens = allergens
    }

    func isAllowed(for diet: Diet, avoiding allergies: Set<Allergen>) -> Bool {
        self.diet <= diet && allergens.isDisjoint(with: allergies)
    }

    static func == (lhs: Remedy, rhs: Remedy) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct RemedyPackage: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let summary: String
    let remedies: [Remedy]
    var isCore: Bool = false

    static func == (lhs: RemedyPackage, rhs: RemedyPackage) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

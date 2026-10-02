import Foundation

/// A home-cooked dish (or a "sometimes" treat) that the character can eat.
struct Food: Identifiable, Hashable {
    let id: String
    let name: String
    /// What the family might call it at home, e.g. "Raab" or "Pakhala Bhata".
    let localName: String?
    let emoji: String
    let blurb: String
    /// Nutrients this dish is a good source of, strongest first.
    let nutrients: [Nutrient]
    let diet: Diet
    let allergens: Set<Allergen>
    /// Festival / party foods: tasty, fine sometimes, but they don't help in a mission.
    let isSometimes: Bool

    init(_ id: String,
         _ name: String,
         local: String? = nil,
         _ emoji: String,
         _ nutrients: [Nutrient],
         _ blurb: String,
         diet: Diet = .vegetarian,
         allergens: Set<Allergen> = [],
         sometimes: Bool = false) {
        self.id = id
        self.name = name
        self.localName = local
        self.emoji = emoji
        self.nutrients = nutrients
        self.blurb = blurb
        self.diet = diet
        self.allergens = allergens
        self.isSometimes = sometimes
    }

    /// Superpowers, derived from nutrients so the game can always explain *why*.
    var benefits: Set<Benefit> {
        isSometimes ? [] : Set(nutrients.flatMap(\.benefits))
    }

    var macros: [Nutrient] { nutrients.filter(\.isMacro) }
    var micros: [Nutrient] { nutrients.filter { !$0.isMacro } }

    /// Which of this food's nutrients produce a given benefit.
    func nutrients(giving benefit: Benefit) -> [Nutrient] {
        nutrients.filter { $0.benefits.contains(benefit) }
    }

    func isAllowed(for diet: Diet, avoiding allergies: Set<Allergen>) -> Bool {
        self.diet <= diet && allergens.isDisjoint(with: allergies)
    }

    static func == (lhs: Food, rhs: Food) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum PackageRegion: String, CaseIterable, Codable {
    case everyday = "Everyday"
    case india = "Indian Home Kitchens"
    case world = "Kitchens Around the World"
    case remedies = "Home Remedies"
}

/// A curated set of dishes from one food culture. Parents pick which packages
/// stock the in-game pantry.
struct FoodPackage: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let region: PackageRegion
    let summary: String
    let foods: [Food]
    /// Always included (so every mission stays solvable).
    var isCore: Bool = false

    static func == (lhs: FoodPackage, rhs: FoodPackage) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

import Foundation

/// A home-cooked dish (or a "sometimes" treat) that the character can eat.
/// Dishes live in JSON kitchen packs (see `PackTemplates/kitchen.template.json`)
/// or are made by parents in the Family Kitchen editor.
struct Food: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    /// What the family calls it at home, e.g. "Raab", "Frijoles de olla", "Okayu".
    var localName: String?
    var emoji: String
    var blurb: String
    /// Nutrients this dish is a good source of, strongest first.
    var nutrients: [Nutrient]
    var diet: Diet
    var allergens: Set<Allergen>
    /// Festival / party foods: tasty, fine sometimes, but they don't help in a mission.
    var isSometimes: Bool
    /// What kind of dish it is. Used to spot classic pairings like dal + rice.
    var tags: Set<FoodTag> = []

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

    enum CodingKeys: String, CodingKey {
        case id, name, localName, emoji, blurb, nutrients, tags, diet, allergens
        case isSometimes = "sometimes"
    }

    /// Only id, name, emoji and nutrients are required; everything else has a safe default.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        localName = try c.decodeIfPresent(String.self, forKey: .localName)
        emoji = try c.decode(String.self, forKey: .emoji)
        blurb = try c.decodeIfPresent(String.self, forKey: .blurb) ?? ""
        nutrients = try c.decode([Nutrient].self, forKey: .nutrients)
        diet = try c.decodeIfPresent(Diet.self, forKey: .diet) ?? .vegetarian
        allergens = try c.decodeIfPresent(Set<Allergen>.self, forKey: .allergens) ?? []
        isSometimes = try c.decodeIfPresent(Bool.self, forKey: .isSometimes) ?? false
        tags = try c.decodeIfPresent(Set<FoodTag>.self, forKey: .tags) ?? []
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

/// Kinds of dishes, used for pairings and for parents' dish templates.
enum FoodTag: String, CaseIterable, Codable, Identifiable {
    case legume, grain, greens, fermented

    var id: String { rawValue }

    var name: String {
        switch self {
        case .legume: return "Beans, lentils, peas or soy"
        case .grain: return "Grain (rice, wheat, corn, millet…)"
        case .greens: return "Leafy greens"
        case .fermented: return "Fermented"
        }
    }
}

/// Where in the world a pack comes from. Used to group packs for parents.
enum WorldRegion: String, CaseIterable, Codable, Identifiable {
    case everyday, family
    case southAsia, eastAsia, southeastAsia, middleEast, africa, europe, latinAmerica, northAmerica, oceania

    var id: String { rawValue }

    var name: String {
        switch self {
        case .everyday: return "Everyday"
        case .family: return "Our Family"
        case .southAsia: return "South Asia"
        case .eastAsia: return "East Asia"
        case .southeastAsia: return "Southeast Asia"
        case .middleEast: return "Middle East & North Africa"
        case .africa: return "Africa"
        case .europe: return "Europe"
        case .latinAmerica: return "Latin America & the Caribbean"
        case .northAmerica: return "North America"
        case .oceania: return "Oceania & the Pacific"
        }
    }

    var emoji: String {
        switch self {
        case .everyday: return "🧺"
        case .family: return "💛"
        case .southAsia: return "🪷"
        case .eastAsia: return "🏮"
        case .southeastAsia: return "🌴"
        case .middleEast: return "🫒"
        case .africa: return "🌍"
        case .europe: return "🏰"
        case .latinAmerica: return "🌽"
        case .northAmerica: return "🍁"
        case .oceania: return "🌊"
        }
    }
}

/// A curated set of dishes from one food culture. Parents pick which packs
/// stock the in-game pantry.
struct FoodPackage: Identifiable, Hashable, Codable {
    var id: String
    var name: String
    var emoji: String
    var region: WorldRegion
    /// ISO country codes this kitchen is common in; used to suggest packs.
    var countries: [String]
    /// What children in this culture call their grandparents (Dadi, Abuela, Obaachan…).
    var elderNames: [String]
    var summary: String
    var foods: [Food]
    /// Always included (so every mission stays solvable).
    var isCore: Bool
    /// Suggested first for its countries (e.g. the most widely cooked cuisines of a big country).
    var isFeatured: Bool = false

    init(id: String, name: String, emoji: String, region: WorldRegion, countries: [String] = [],
         elderNames: [String] = [], summary: String, foods: [Food], isCore: Bool = false) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.region = region
        self.countries = countries
        self.elderNames = elderNames
        self.summary = summary
        self.foods = foods
        self.isCore = isCore
    }

    enum CodingKeys: String, CodingKey {
        case id, name, emoji, region, countries, elderNames, summary, isCore, foods
        case isFeatured = "featured"
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        emoji = try c.decode(String.self, forKey: .emoji)
        region = try c.decode(WorldRegion.self, forKey: .region)
        countries = try c.decodeIfPresent([String].self, forKey: .countries) ?? []
        elderNames = try c.decodeIfPresent([String].self, forKey: .elderNames) ?? []
        summary = try c.decodeIfPresent(String.self, forKey: .summary) ?? ""
        foods = try c.decode([Food].self, forKey: .foods)
        isCore = try c.decodeIfPresent(Bool.self, forKey: .isCore) ?? false
        isFeatured = try c.decodeIfPresent(Bool.self, forKey: .isFeatured) ?? false
    }

    static func == (lhs: FoodPackage, rhs: FoodPackage) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

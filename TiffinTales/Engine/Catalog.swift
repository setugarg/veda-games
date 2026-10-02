import Foundation

/// Everything a family has stocked, after applying their diet and allergies.
struct Pantry {
    /// Everyday healthy dishes.
    let foods: [Food]
    /// "Sometimes" treats used as gentle distractors.
    let treats: [Food]
    let remedies: [Remedy]
}

enum Catalog {
    /// The loaded packs. Replaceable so tools and tests can load packs from disk.
    static var library = ContentLibrary.shared

    static var foodPackages: [FoodPackage] { library.foodPacks }
    static var remedyPackages: [RemedyPackage] { library.remedyPacks }

    static var allFoods: [Food] { foodPackages.flatMap(\.foods) }
    static var allRemedies: [Remedy] { remedyPackages.flatMap(\.remedies) }

    static func food(id: String) -> Food? { allFoods.first { $0.id == id } }
    static func remedy(id: String) -> Remedy? { allRemedies.first { $0.id == id } }

    static func pantry(for settings: FamilySettings) -> Pantry {
        let packages = foodPackages.filter { $0.isCore || settings.foodPackages.contains($0.id) }
        let allowed = unique(packages.flatMap(\.foods)
            .filter { $0.isAllowed(for: settings.diet, avoiding: settings.allergies) })

        let remedyPacks = remedyPackages.filter { $0.isCore || settings.remedyPackages.contains($0.id) }
        let remedies = unique(remedyPacks.flatMap(\.remedies)
            .filter { $0.isAllowed(for: settings.diet, avoiding: settings.allergies) })

        return Pantry(foods: allowed.filter { !$0.isSometimes },
                      treats: allowed.filter(\.isSometimes),
                      remedies: remedies)
    }

    /// Packs to start with for a family in a given country (from the device region).
    static func suggestedPacks(forCountry country: String?) -> (food: Set<String>, remedies: Set<String>, elder: String) {
        let code = country?.uppercased() ?? ""
        let kitchens = library.builtInFoodPacks
            .filter { !$0.isCore && $0.countries.contains(code) }
            .sorted { ($0.isFeatured ? 0 : 1, $0.name) < ($1.isFeatured ? 0 : 1, $1.name) }
        let remedies = library.builtInRemedyPacks.filter { !$0.isCore && $0.countries.contains(code) }
        // Unknown country: a mix from around the world.
        let foodIDs = kitchens.isEmpty ? ["western", "greek", "japanese", "mexican"] : kitchens.prefix(4).map(\.id)
        let remedyIDs = remedies.isEmpty ? ["western-remedies"] : remedies.prefix(2).map(\.id)
        let elder = kitchens.first?.elderNames.first ?? "Grandma"
        return (Set(foodIDs), Set(remedyIDs), elder)
    }

    /// Grandparent names from the family's kitchens, for the settings picker.
    static func elderNameSuggestions(for settings: FamilySettings) -> [String] {
        var names: [String] = []
        for pack in foodPackages where settings.foodPackages.contains(pack.id) {
            for name in pack.elderNames where !names.contains(name) { names.append(name) }
        }
        for name in ["Grandma", "Grandpa", "Nana"] where !names.contains(name) { names.append(name) }
        return names
    }

    /// Picks the version of a wisdom topic that fits this family: their own
    /// culture's tradition first, then the shared version.
    static func wisdom<R: RandomNumberGenerator>(for topic: WisdomTopic, settings: FamilySettings, using rng: inout R) -> Wisdom? {
        let cards = WisdomContent.all.filter { $0.topic == topic }
        let allowed = cards.filter { $0.isAllowed(for: settings.diet, avoiding: settings.allergies) }
        let families = settings.foodPackages.union(settings.remedyPackages)
        let ours = allowed.filter { !$0.cultures.isDisjoint(with: families) }
        if let pick = ours.randomElement(using: &rng) { return pick }
        return allowed.first(where: \.isUniversal) ?? allowed.first ?? cards.first
    }

    /// Wisdom cards a family would recognise: shared ones plus their own cultures'.
    static func familiarWisdom(for settings: FamilySettings) -> [Wisdom] {
        let families = settings.foodPackages.union(settings.remedyPackages)
        return WisdomContent.all.filter { $0.isUniversal || !$0.cultures.isDisjoint(with: families) }
    }

    /// Which pack a dish comes from (for the "From Gujarati Rasoi" label).
    static func package(of food: Food) -> FoodPackage? {
        foodPackages.first { $0.foods.contains(food) }
    }

    static func package(of remedy: Remedy) -> RemedyPackage? {
        remedyPackages.first { $0.remedies.contains(remedy) }
    }

    private static func unique<T: Identifiable>(_ items: [T]) -> [T] where T.ID == String {
        var seen = Set<String>()
        return items.filter { seen.insert($0.id).inserted }
    }
}

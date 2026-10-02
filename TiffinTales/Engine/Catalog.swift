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
    static let foodPackages: [FoodPackage] = [EverydayContent.basics] + IndiaPackages.all + WorldPackages.all
    static let remedyPackages: [RemedyPackage] = RemedyPackages.all

    static let allFoods: [Food] = foodPackages.flatMap(\.foods) + EverydayContent.sometimes
    static let allRemedies: [Remedy] = remedyPackages.flatMap(\.remedies)

    static func food(id: String) -> Food? { allFoods.first { $0.id == id } }
    static func remedy(id: String) -> Remedy? { allRemedies.first { $0.id == id } }

    static func pantry(for settings: FamilySettings) -> Pantry {
        let packages = foodPackages.filter { $0.isCore || settings.foodPackages.contains($0.id) }
        let stocked = packages.flatMap(\.foods) + EverydayContent.sometimes
        let allowed = unique(stocked.filter { $0.isAllowed(for: settings.diet, avoiding: settings.allergies) })

        let remedyPacks = remedyPackages.filter { $0.isCore || settings.remedyPackages.contains($0.id) }
        let remedies = unique(remedyPacks.flatMap(\.remedies)
            .filter { $0.isAllowed(for: settings.diet, avoiding: settings.allergies) })

        return Pantry(foods: allowed.filter { !$0.isSometimes },
                      treats: allowed.filter(\.isSometimes),
                      remedies: remedies)
    }

    /// Which package a dish comes from (for the "From Gujarati Rasoi" label).
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

import Foundation

/// Loads food and remedy packs from JSON files, and merges in the family's own
/// custom dishes and remedies. Adding a culture is a data change: drop a new
/// `kitchen-*.json` or `remedies-*.json` file into `Resources/Packs`.
final class ContentLibrary {
    static let familyKitchenID = "family-kitchen"
    static let familyRemediesID = "family-remedies"

    let builtInFoodPacks: [FoodPackage]
    let builtInRemedyPacks: [RemedyPackage]
    /// Problems found while loading (shown in debug builds and by the content check).
    let loadErrors: [String]

    /// Dishes and remedies a family created themselves.
    var familyFoods: [Food] = []
    var familyRemedies: [Remedy] = []

    init(packFiles: [URL]) {
        var foodPacks: [FoodPackage] = []
        var remedyPacks: [RemedyPackage] = []
        var errors: [String] = []
        let decoder = JSONDecoder()

        for url in packFiles {
            do {
                let data = try Data(contentsOf: url)
                if url.lastPathComponent.hasPrefix("remedies-") {
                    remedyPacks.append(try decoder.decode(RemedyPackage.self, from: data))
                } else {
                    foodPacks.append(try decoder.decode(FoodPackage.self, from: data))
                }
            } catch {
                errors.append("\(url.lastPathComponent): \(error)")
            }
        }

        builtInFoodPacks = foodPacks.sorted(by: Self.packOrder)
        builtInRemedyPacks = remedyPacks.sorted { ($0.isCore ? 0 : 1, Self.regionRank($0.region), $0.name) < ($1.isCore ? 0 : 1, Self.regionRank($1.region), $1.name) }
        loadErrors = errors
    }

    /// Every pack, with the family's own kitchen first when it has dishes.
    var foodPacks: [FoodPackage] {
        guard !familyFoods.isEmpty else { return builtInFoodPacks }
        let family = FoodPackage(id: Self.familyKitchenID, name: "Our Family Kitchen", emoji: "💛", region: .family,
                                 summary: "Dishes your family added.", foods: familyFoods, isCore: true)
        return [family] + builtInFoodPacks
    }

    var remedyPacks: [RemedyPackage] {
        guard !familyRemedies.isEmpty else { return builtInRemedyPacks }
        let family = RemedyPackage(id: Self.familyRemediesID, name: "Our Family Remedies", emoji: "💛", region: .family,
                                   summary: "Remedies your family trusts.", remedies: familyRemedies, isCore: true)
        return [family] + builtInRemedyPacks
    }

    // MARK: Loading

    static let shared = ContentLibrary(packFiles: packFiles(in: Bundle.main.resourceURL))

    /// Every pack file under a folder. Files starting with "_" are ignored, so
    /// templates can sit next to real packs.
    static func packFiles(in directory: URL?) -> [URL] {
        guard let directory,
              let enumerator = FileManager.default.enumerator(at: directory, includingPropertiesForKeys: nil) else { return [] }
        return enumerator.compactMap { $0 as? URL }
            .filter { url in
                let name = url.lastPathComponent
                return url.pathExtension == "json" && !name.hasPrefix("_")
                    && (name.hasPrefix("kitchen-") || name.hasPrefix("remedies-"))
            }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
    }

    private static func regionRank(_ region: WorldRegion) -> Int {
        WorldRegion.allCases.firstIndex(of: region) ?? 0
    }

    private static func packOrder(_ a: FoodPackage, _ b: FoodPackage) -> Bool {
        (a.isCore ? 0 : 1, regionRank(a.region), a.name) < (b.isCore ? 0 : 1, regionRank(b.region), b.name)
    }
}

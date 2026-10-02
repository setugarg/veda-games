import Foundation
import Observation

/// App-wide state: the family's settings and the child's progress, saved locally.
@Observable
final class GameStore {
    var settings: FamilySettings
    var progress: PlayerProgress

    private let defaults: UserDefaults
    private static let settingsKey = "tiffin.settings.v1"
    private static let progressKey = "tiffin.progress.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        settings = Self.load(FamilySettings.self, key: Self.settingsKey, from: defaults) ?? FamilySettings()
        progress = Self.load(PlayerProgress.self, key: Self.progressKey, from: defaults) ?? PlayerProgress()
    }

    var name: String { settings.displayName }

    var pantry: Pantry { Catalog.pantry(for: settings) }

    func saveSettings() { save(settings, key: Self.settingsKey) }
    func saveProgress() { save(progress, key: Self.progressKey) }

    // MARK: Story progress

    func completeMeal(_ mission: Mission, stars: Int, plate: [Food]) {
        progress.record(stars: stars, for: mission)
        for food in plate where !food.isSometimes {
            progress.triedFoods.insert(food.id)
            progress.discoveredNutrients.formUnion(food.nutrients)
        }
        saveProgress()
    }

    func completeRemedy(_ mission: Mission, stars: Int, remedy: Remedy) {
        progress.record(stars: stars, for: mission)
        progress.learnedRemedies.insert(remedy.id)
        saveProgress()
    }

    func nextMission(after mission: Mission) -> Mission? {
        let all = StoryContent.allMissions
        guard let index = all.firstIndex(of: mission), index + 1 < all.count else { return nil }
        return all[index + 1]
    }

    func chapter(of mission: Mission) -> Chapter? {
        StoryContent.chapters.first { $0.missions.contains(mission) }
    }

    func resetProgress() {
        progress = PlayerProgress()
        saveProgress()
    }

    // MARK: Persistence

    private func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, key: String, from defaults: UserDefaults) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

import Foundation
import Observation

/// App-wide state: the family's settings and the child's progress, saved locally.
@Observable
final class GameStore {
    var settings: FamilySettings
    var progress: PlayerProgress
    /// Tips, remedies and recorded stories from the child's own family.
    var familyTips: [FamilyTip]

    private let defaults: UserDefaults
    private static let settingsKey = "tiffin.settings.v1"
    private static let progressKey = "tiffin.progress.v1"
    private static let familyKey = "tiffin.family.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        settings = Self.load(FamilySettings.self, key: Self.settingsKey, from: defaults) ?? FamilySettings()
        progress = Self.load(PlayerProgress.self, key: Self.progressKey, from: defaults) ?? PlayerProgress()
        familyTips = Self.load([FamilyTip].self, key: Self.familyKey, from: defaults) ?? []
    }

    var name: String { settings.displayName }
    var elder: String { settings.displayElder }

    /// Fills in `{name}` and `{elder}`.
    func text(_ template: String) -> String { template.personalized(name, elder: elder) }

    var pantry: Pantry { Catalog.pantry(for: settings) }

    func saveSettings() { save(settings, key: Self.settingsKey) }
    func saveProgress() { save(progress, key: Self.progressKey) }

    // MARK: Story progress

    func completeMeal(_ mission: Mission, stars: Int, plate: [Food], combos: [Combo]) {
        progress.record(stars: stars, for: mission)
        for food in plate where !food.isSometimes {
            progress.triedFoods.insert(food.id)
            progress.discoveredNutrients.formUnion(food.nutrients)
        }
        progress.discoveredCombos.formUnion(combos.map(\.id))
        saveProgress()
    }

    func completeWisdom(_ mission: Mission, stars: Int, wisdom: Wisdom) {
        progress.record(stars: stars, for: mission)
        progress.learnedWisdom.insert(wisdom.id)
        saveProgress()
    }

    func completeElderInterview(_ mission: Mission, tip: FamilyTip?) {
        progress.record(stars: 3, for: mission)
        saveProgress()
        if let tip { addFamilyTip(tip) }
    }

    // MARK: Family wisdom

    func addFamilyTip(_ tip: FamilyTip) {
        familyTips.insert(tip, at: 0)
        saveFamily()
    }

    func deleteFamilyTip(_ tip: FamilyTip) {
        if let file = tip.audioFile { VoiceFiles.delete(file) }
        familyTips.removeAll { $0.id == tip.id }
        saveFamily()
    }

    func saveFamily() { save(familyTips, key: Self.familyKey) }

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

/// Where family voice recordings live (on device only, never uploaded).
enum VoiceFiles {
    static var directory: URL {
        let base = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dir = base.appendingPathComponent("FamilyVoices", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    static func url(for file: String) -> URL { directory.appendingPathComponent(file) }

    static func newFileName() -> String { UUID().uuidString + ".m4a" }

    static func delete(_ file: String) { try? FileManager.default.removeItem(at: url(for: file)) }
}

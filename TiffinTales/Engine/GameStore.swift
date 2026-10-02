import Foundation
import Observation

/// App-wide state: the family's settings and the child's progress, saved locally.
@Observable
final class GameStore {
    var settings: FamilySettings
    var progress: PlayerProgress
    /// Tips, remedies and recorded stories from the child's own family.
    var familyTips: [FamilyTip]
    /// Dishes and remedies the family created in the grown-up area.
    var familyFoods: [Food] { didSet { Catalog.library.familyFoods = familyFoods } }
    var familyRemedies: [Remedy] { didSet { Catalog.library.familyRemedies = familyRemedies } }

    private let defaults: UserDefaults
    private static let settingsKey = "tiffin.settings.v1"
    private static let progressKey = "tiffin.progress.v1"
    private static let familyKey = "tiffin.family.v1"
    private static let familyFoodsKey = "tiffin.familyFoods.v1"
    private static let familyRemediesKey = "tiffin.familyRemedies.v1"

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        settings = Self.load(FamilySettings.self, key: Self.settingsKey, from: defaults)
            ?? FamilySettings.suggested(forCountry: Locale.current.region?.identifier)
        progress = Self.load(PlayerProgress.self, key: Self.progressKey, from: defaults) ?? PlayerProgress()
        familyTips = Self.load([FamilyTip].self, key: Self.familyKey, from: defaults) ?? []
        familyFoods = Self.load([Food].self, key: Self.familyFoodsKey, from: defaults) ?? []
        familyRemedies = Self.load([Remedy].self, key: Self.familyRemediesKey, from: defaults) ?? []
        Catalog.library.familyFoods = familyFoods
        Catalog.library.familyRemedies = familyRemedies
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

    // MARK: Family kitchen & remedies

    /// Adds a new family dish, or replaces one with the same id.
    func saveFamilyFood(_ food: Food) {
        if let index = familyFoods.firstIndex(where: { $0.id == food.id }) {
            familyFoods[index] = food
        } else {
            familyFoods.insert(food, at: 0)
        }
        save(familyFoods, key: Self.familyFoodsKey)
    }

    func deleteFamilyFood(_ food: Food) {
        familyFoods.removeAll { $0.id == food.id }
        save(familyFoods, key: Self.familyFoodsKey)
    }

    func saveFamilyRemedy(_ remedy: Remedy) {
        if let index = familyRemedies.firstIndex(where: { $0.id == remedy.id }) {
            if let old = familyRemedies[index].audioFile, old != remedy.audioFile { VoiceFiles.delete(old) }
            familyRemedies[index] = remedy
        } else {
            familyRemedies.insert(remedy, at: 0)
        }
        save(familyRemedies, key: Self.familyRemediesKey)
    }

    func deleteFamilyRemedy(_ remedy: Remedy) {
        if let file = remedy.audioFile { VoiceFiles.delete(file) }
        familyRemedies.removeAll { $0.id == remedy.id }
        save(familyRemedies, key: Self.familyRemediesKey)
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

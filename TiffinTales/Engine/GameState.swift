import Foundation

/// How the child's character looks. Picked together in the grown-up area.
struct AvatarStyle: Codable, Equatable {
    var skinTone: Int = 1
    var hairStyle: Int = 1
    var hairColor: Int = 0
    var outfitColor: Int = 0
}

/// Set by a parent behind the grown-up gate.
struct FamilySettings: Codable, Equatable {
    var childName: String = "Veda"
    var diet: Diet = .vegetarian
    var allergies: Set<Allergen> = []
    var foodPackages: Set<String> = ["baniya", "gujarati"]
    var remedyPackages: Set<String> = ["dadi-nani"]
    var avatar = AvatarStyle()
    var readAloud: Bool = true
    var hasCompletedSetup: Bool = false
    /// What the child calls the grandparent who teaches in the story: Dadi, Nani, Ba, Aaji, Paati, Abuela…
    var elderName: String = "Dadi"

    var displayName: String {
        let trimmed = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Veda" : trimmed
    }

    var displayElder: String {
        let trimmed = elderName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Dadi" : trimmed
    }

    init() {}

    // Tolerant decoding, so adding settings in an update never wipes a family's choices.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let d = FamilySettings()
        childName = try c.decodeIfPresent(String.self, forKey: .childName) ?? d.childName
        diet = try c.decodeIfPresent(Diet.self, forKey: .diet) ?? d.diet
        allergies = try c.decodeIfPresent(Set<Allergen>.self, forKey: .allergies) ?? d.allergies
        foodPackages = try c.decodeIfPresent(Set<String>.self, forKey: .foodPackages) ?? d.foodPackages
        remedyPackages = try c.decodeIfPresent(Set<String>.self, forKey: .remedyPackages) ?? d.remedyPackages
        avatar = try c.decodeIfPresent(AvatarStyle.self, forKey: .avatar) ?? d.avatar
        readAloud = try c.decodeIfPresent(Bool.self, forKey: .readAloud) ?? d.readAloud
        hasCompletedSetup = try c.decodeIfPresent(Bool.self, forKey: .hasCompletedSetup) ?? d.hasCompletedSetup
        elderName = try c.decodeIfPresent(String.self, forKey: .elderName) ?? d.elderName
    }
}

struct PlayerProgress: Codable, Equatable {
    var stars: [String: Int] = [:]
    var discoveredNutrients: Set<Nutrient> = []
    var learnedRemedies: Set<String> = []
    var triedFoods: Set<String> = []
    var hasSeenPrologue: Bool = false
    var learnedWisdom: Set<String> = []
    var discoveredCombos: Set<String> = []

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        stars = try c.decodeIfPresent([String: Int].self, forKey: .stars) ?? [:]
        discoveredNutrients = try c.decodeIfPresent(Set<Nutrient>.self, forKey: .discoveredNutrients) ?? []
        learnedRemedies = try c.decodeIfPresent(Set<String>.self, forKey: .learnedRemedies) ?? []
        triedFoods = try c.decodeIfPresent(Set<String>.self, forKey: .triedFoods) ?? []
        hasSeenPrologue = try c.decodeIfPresent(Bool.self, forKey: .hasSeenPrologue) ?? false
        learnedWisdom = try c.decodeIfPresent(Set<String>.self, forKey: .learnedWisdom) ?? []
        discoveredCombos = try c.decodeIfPresent(Set<String>.self, forKey: .discoveredCombos) ?? []
    }

    var totalStars: Int { stars.values.reduce(0, +) }

    func isCompleted(_ mission: Mission) -> Bool { (stars[mission.id] ?? 0) > 0 }

    func isUnlocked(_ mission: Mission) -> Bool {
        let all = StoryContent.allMissions
        guard let index = all.firstIndex(of: mission) else { return false }
        return index == 0 || isCompleted(all[index - 1])
    }

    /// The first mission not yet completed, to resume the story.
    var nextMission: Mission? {
        StoryContent.allMissions.first { !isCompleted($0) }
    }

    mutating func record(stars newStars: Int, for mission: Mission) {
        stars[mission.id] = max(stars[mission.id] ?? 0, newStars)
    }
}

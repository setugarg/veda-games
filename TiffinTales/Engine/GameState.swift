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

    var displayName: String {
        let trimmed = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Veda" : trimmed
    }
}

struct PlayerProgress: Codable, Equatable {
    var stars: [String: Int] = [:]
    var discoveredNutrients: Set<Nutrient> = []
    var learnedRemedies: Set<String> = []
    var triedFoods: Set<String> = []
    var hasSeenPrologue: Bool = false

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

// Content sanity checks. Run on any machine with a Swift toolchain:
//   swiftc TiffinTales/Models/*.swift TiffinTales/Content/*.swift TiffinTales/Engine/*.swift Tools/ContentCheck.swift -o /tmp/content-check && /tmp/content-check
import Foundation

var failures = 0
func check(_ condition: Bool, _ message: @autoclosure () -> String) {
    if !condition { failures += 1; print("FAIL:", message()) }
}

@main
struct ContentCheck {
    static func main() {
        // Unique ids
        let foodIDs = Catalog.allFoods.map(\.id)
        check(Set(foodIDs).count == foodIDs.count, "duplicate food ids: \(Dictionary(grouping: foodIDs, by: { $0 }).filter { $0.value.count > 1 }.keys)")
        let remedyIDs = Catalog.allRemedies.map(\.id)
        check(Set(remedyIDs).count == remedyIDs.count, "duplicate remedy ids")
        let missionIDs = StoryContent.allMissions.map(\.id)
        check(Set(missionIDs).count == missionIDs.count, "duplicate mission ids")
        let pkgIDs = Catalog.foodPackages.map(\.id) + Catalog.remedyPackages.map(\.id)
        check(Set(pkgIDs).count == pkgIDs.count, "duplicate package ids")

        // Core care covers every ailment
        for ailment in Ailment.allCases {
            check(RemedyPackages.everydayCare.remedies.contains { $0.treats.contains(ailment) }, "no core remedy for \(ailment)")
        }

        // Every mission winnable under many settings, including very strict ones.
        var strict = FamilySettings()
        strict.diet = .vegan
        strict.allergies = Set(Allergen.allCases)
        strict.foodPackages = []
        strict.remedyPackages = []
        let defaults = FamilySettings()
        var everything = FamilySettings()
        everything.diet = .nonVegetarian
        everything.foodPackages = Set(Catalog.foodPackages.map(\.id))
        everything.remedyPackages = Set(Catalog.remedyPackages.map(\.id))
        var rng = SystemRandomNumberGenerator()
        for (label, settings) in [("strict", strict), ("default", defaults), ("everything", everything)] {
            let pantry = Catalog.pantry(for: settings)
            for _ in 0..<50 {
                for mission in StoryContent.allMissions {
                    if let topic = mission.wisdomTopic {
                        let card = Catalog.wisdom(for: topic, settings: settings, using: &rng)
                        check(card != nil, "\(label): \(mission.id) no wisdom card for \(topic)")
                        if let card, label == "strict" {
                            check(card.isAllowed(for: settings.diet, avoiding: settings.allergies), "strict: \(mission.id) wisdom \(card.id) breaks diet/allergies")
                        }
                    } else if mission.elderQuestion != nil {
                        continue
                    } else if let ailment = mission.ailment {
                        let choices = MissionEngine.remedyChoices(for: ailment, pantry: pantry, using: &rng)
                        check(choices.contains(where: \.isCorrect), "\(label): \(mission.id) has no correct remedy")
                        check(Set(choices.map(\.id)).count == choices.count, "\(label): \(mission.id) duplicate remedy cards")
                    } else {
                        let options = MissionEngine.mealOptions(for: mission, pantry: pantry, allowedDiet: settings.diet, familyAllergies: settings.allergies, using: &rng)
                        check(options.count <= MissionEngine.optionCount, "\(label): \(mission.id) too many options")
                        check(Set(options.map(\.id)).count == options.count, "\(label): \(mission.id) duplicate cards")
                        let needs = MissionEngine.achievableNeeds(for: mission, options: options)
                        if label != "strict" {
                            check(needs.count == mission.needs.count, "\(label): \(mission.id) needs not all achievable: \(mission.needs) vs \(needs)")
                        }
                        // Greedy: can 3 safe foods cover the needs?
                        let safe = options.filter { f in !f.isSometimes && !(mission.avoid.map { f.allergens.contains($0) } ?? false) }
                        var remaining = Set(needs); var plate: [Food] = []
                        while !remaining.isEmpty, plate.count < MissionEngine.plateSize,
                              let best = safe.filter({ !plate.contains($0) }).max(by: { $0.benefits.intersection(remaining).count < $1.benefits.intersection(remaining).count }),
                              !best.benefits.intersection(remaining).isEmpty {
                            plate.append(best); remaining.subtract(best.benefits)
                        }
                        check(remaining.isEmpty, "\(label): \(mission.id) not solvable with 3 foods, missing \(remaining)")
                        check(MissionEngine.evaluate(plate: plate, needs: needs, avoid: mission.avoid).success, "\(label): \(mission.id) evaluate failed")
                    }
                }
            }
        }

        // Wisdom: every topic has a shared card that works for any family.
        for topic in WisdomTopic.allCases {
            let universal = WisdomContent.all.filter { $0.topic == topic && $0.isUniversal }
            check(universal.contains { $0.diet == .vegan && $0.allergens.isEmpty }, "topic \(topic) has no universal vegan, allergen-free card")
        }
        let wisdomIDs = WisdomContent.all.map(\.id)
        check(Set(wisdomIDs).count == wisdomIDs.count, "duplicate wisdom ids")
        let validCultures = Set(Catalog.foodPackages.map(\.id))
        for card in WisdomContent.all {
            check(card.cultures.isSubset(of: validCultures), "wisdom \(card.id) has unknown culture \(card.cultures.subtracting(validCultures))")
            check(card.distractors.count == 3, "wisdom \(card.id) needs 3 distractors")
        }
        let foodIDSet = Set(foodIDs)
        for id in WisdomContent.legumeDishes.union(WisdomContent.grainDishes) {
            check(foodIDSet.contains(id), "combo list references unknown food \(id)")
        }
        let comboIDs = WisdomContent.combos.map(\.id)
        check(Set(comboIDs).count == comboIDs.count, "duplicate combo ids")
        let topicsInStory = Set(StoryContent.allMissions.compactMap(\.wisdomTopic))
        check(topicsInStory == Set(WisdomTopic.allCases), "topics not used in story: \(Set(WisdomTopic.allCases).subtracting(topicsInStory))")
        // The classic dal-chawal plate should be spotted as a combo.
        if let dal = Catalog.food(id: "arhar-dal") {
            check(MissionEngine.combos(on: [dal]).contains { $0.id == "complete-protein" }, "dal-chawal not detected as complete protein")
        }

        // Benefit coverage per nutrient
        for benefit in Benefit.allCases { check(!benefit.sources.isEmpty, "benefit \(benefit) has no nutrient source") }

        let foods = Catalog.allFoods.count, remedies = Catalog.allRemedies.count
        print("Packages: \(Catalog.foodPackages.count) food, \(Catalog.remedyPackages.count) remedy | foods: \(foods) | remedies: \(remedies) | missions: \(StoryContent.allMissions.count) | wisdom: \(WisdomContent.all.count) | combos: \(WisdomContent.combos.count)")
        print(failures == 0 ? "All content checks passed ✅" : "\(failures) failures ❌")
        exit(failures == 0 ? 0 : 1)
    }
}

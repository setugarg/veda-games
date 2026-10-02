import Foundation

/// One way a benefit got covered: "🧠 Focus ← Rajma Chawal (Iron)".
struct BenefitSource: Hashable {
    let benefit: Benefit
    let food: Food
    let nutrients: [Nutrient]
}

struct MealResult {
    let covered: Set<Benefit>
    let missing: [Benefit]
    let sources: [BenefitSource]
    let treatsEaten: [Food]
    let allergenFoods: [Food]
    /// Grandma Combos found on the plate.
    let combos: [Combo]

    var success: Bool { missing.isEmpty && allergenFoods.isEmpty }
}

/// A card shown in a remedy mission. Either a real remedy or a tempting treat.
struct RemedyChoice: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let remedy: Remedy?
    let treat: Food?
    let isCorrect: Bool
}

enum RemedyResult {
    case soothed(Remedy)
    case wrongRemedy(Remedy, meantFor: Ailment)
    case treat(Food)
}

enum MissionEngine {
    static let plateSize = 3
    static let optionCount = 9

    // MARK: Meal missions

    /// Builds a 3x3 grid of choices that always contains a way to win.
    static func mealOptions<R: RandomNumberGenerator>(for mission: Mission,
                                                      pantry: Pantry,
                                                      allowedDiet: Diet,
                                                      familyAllergies: Set<Allergen>,
                                                      using rng: inout R) -> [Food] {
        let avoid = mission.avoid
        let pool = pantry.foods.filter { food in
            guard let avoid else { return true }
            return !food.allergens.contains(avoid)
        }.shuffled(using: &rng)

        var picks: [Food] = []
        func add(_ food: Food) {
            if !picks.contains(food) { picks.append(food) }
        }

        // Up to two helpful foods per need, so there's a real choice to make.
        for need in mission.needs {
            pool.filter { $0.benefits.contains(need) }.prefix(2).forEach(add)
        }

        // Traps for allergy-safety missions, so kids practise checking.
        var traps: [Food] = []
        if let avoid, !familyAllergies.contains(avoid) {
            let candidates = (pantry.foods + pantry.treats).filter { $0.allergens.contains(avoid) }
            let fallback = Catalog.allFoods.filter {
                $0.allergens.contains(avoid) && $0.isAllowed(for: allowedDiet, avoiding: familyAllergies)
            }
            traps = Array((candidates.isEmpty ? fallback : candidates).shuffled(using: &rng).prefix(2))
        }

        let treats = Array(pantry.treats.filter { !traps.contains($0) }.shuffled(using: &rng).prefix(2))
        let fillTarget = optionCount - traps.count - treats.count
        for food in pool where picks.count < fillTarget { add(food) }

        return (Array(picks.prefix(fillTarget)) + traps + treats).shuffled(using: &rng)
    }

    /// Needs that can actually be met with the cards on screen. Very restrictive
    /// pantries never make a mission impossible.
    static func achievableNeeds(for mission: Mission, options: [Food]) -> [Benefit] {
        let avoid = mission.avoid
        let available = options
            .filter { food in avoid.map { !food.allergens.contains($0) } ?? true }
            .reduce(into: Set<Benefit>()) { $0.formUnion($1.benefits) }
        return mission.needs.filter(available.contains)
    }

    static func evaluate(plate: [Food], needs: [Benefit], avoid: Allergen?) -> MealResult {
        let treats = plate.filter(\.isSometimes)
        let allergenFoods = avoid.map { allergen in plate.filter { $0.allergens.contains(allergen) } } ?? []

        var sources: [BenefitSource] = []
        for need in needs {
            for food in plate where food.benefits.contains(need) {
                sources.append(BenefitSource(benefit: need, food: food, nutrients: food.nutrients(giving: need)))
            }
        }
        let covered = Set(sources.map(\.benefit))
        return MealResult(covered: covered,
                          missing: needs.filter { !covered.contains($0) },
                          sources: sources,
                          treatsEaten: treats,
                          allergenFoods: allergenFoods,
                          combos: combos(on: plate))
    }

    /// Food pairings grandmas know about, spotted on the plate.
    static func combos(on plate: [Food]) -> [Combo] {
        let everyday = plate.filter { !$0.isSometimes }
        let nutrients = Set(everyday.flatMap(\.nutrients))
        return WisdomContent.combos.filter { combo in
            switch combo.rule {
            case .nutrients(let required):
                return required.allSatisfy(nutrients.contains)
            case .legumeAndGrain:
                return everyday.contains { $0.tags.contains(.legume) }
                    && everyday.contains { $0.tags.contains(.grain) }
            }
        }
    }

    static func stars(for result: MealResult, attempts: Int) -> Int {
        guard result.success else { return 0 }
        if attempts <= 1 && result.treatsEaten.isEmpty { return 3 }
        if attempts <= 2 { return 2 }
        return 1
    }

    // MARK: Remedy missions

    static func remedyChoices<R: RandomNumberGenerator>(for ailment: Ailment,
                                                        pantry: Pantry,
                                                        using rng: inout R) -> [RemedyChoice] {
        let helpful = pantry.remedies.filter { $0.treats.contains(ailment) }
        // The family's own remedy first, then their culture's, then generic everyday care.
        let packID = { (remedy: Remedy) in Catalog.package(of: remedy)?.id }
        let family = helpful.filter { packID($0) == ContentLibrary.familyRemediesID }.shuffled(using: &rng)
        let cultural = helpful.filter { Catalog.package(of: $0)?.isCore != true }.shuffled(using: &rng)
        let generic = helpful.filter { Catalog.package(of: $0)?.isCore == true && packID($0) != ContentLibrary.familyRemediesID }
        let correct = Array((family + cultural + generic).prefix(2))

        let wrong = pantry.remedies
            .filter { !$0.treats.contains(ailment) }
            .shuffled(using: &rng)
            .prefix(3)

        let treat = pantry.treats.shuffled(using: &rng).first

        var choices = correct.map { RemedyChoice(id: $0.id, name: $0.name, emoji: $0.emoji, remedy: $0, treat: nil, isCorrect: true) }
        choices += wrong.map { RemedyChoice(id: $0.id, name: $0.name, emoji: $0.emoji, remedy: $0, treat: nil, isCorrect: false) }
        if let treat {
            choices.append(RemedyChoice(id: treat.id, name: treat.name, emoji: treat.emoji, remedy: nil, treat: treat, isCorrect: false))
        }
        return choices.shuffled(using: &rng)
    }

    static func evaluate(choice: RemedyChoice, for ailment: Ailment) -> RemedyResult {
        if let remedy = choice.remedy {
            if remedy.treats.contains(ailment) { return .soothed(remedy) }
            return .wrongRemedy(remedy, meantFor: remedy.treats.sorted { $0.rawValue < $1.rawValue }.first ?? ailment)
        }
        // Treat choices always carry a food.
        return .treat(choice.treat!)
    }

    // MARK: Wisdom missions

    /// The right answer plus three distractors, shuffled.
    static func wisdomChoices<R: RandomNumberGenerator>(for wisdom: Wisdom, using rng: inout R) -> [WisdomChoice] {
        ([wisdom.answer] + wisdom.distractors).shuffled(using: &rng)
    }

    static func remedyStars(attempts: Int) -> Int {
        switch attempts {
        case ...1: return 3
        case 2: return 2
        default: return 1
        }
    }
}

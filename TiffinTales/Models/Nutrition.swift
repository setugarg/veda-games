import Foundation

/// A nutrient a food is a *good source* of. Macros are the "big" nutrients,
/// micros are the "tiny helpers". Kids learn which superpower each one gives.
enum Nutrient: String, CaseIterable, Codable, Identifiable {
    // Macros (big nutrients)
    case carbs, protein, healthyFats, fiber, water
    // Micros (tiny helpers)
    case iron, calcium, vitaminA, vitaminC, vitaminD, bVitamins
    case potassium, magnesium, zinc, omega3
    // Friendly helpers
    case probiotics

    var id: String { rawValue }

    var isMacro: Bool {
        switch self {
        case .carbs, .protein, .healthyFats, .fiber, .water: return true
        default: return false
        }
    }

    var name: String {
        switch self {
        case .carbs: return "Carbs"
        case .protein: return "Protein"
        case .healthyFats: return "Healthy Fats"
        case .fiber: return "Fiber"
        case .water: return "Water"
        case .iron: return "Iron"
        case .calcium: return "Calcium"
        case .vitaminA: return "Vitamin A"
        case .vitaminC: return "Vitamin C"
        case .vitaminD: return "Vitamin D"
        case .bVitamins: return "B Vitamins"
        case .potassium: return "Potassium"
        case .magnesium: return "Magnesium"
        case .zinc: return "Zinc"
        case .omega3: return "Omega-3"
        case .probiotics: return "Good Bacteria"
        }
    }

    var emoji: String {
        switch self {
        case .carbs: return "🌾"
        case .protein: return "🫘"
        case .healthyFats: return "🥑"
        case .fiber: return "🧹"
        case .water: return "💧"
        case .iron: return "🚚"
        case .calcium: return "🦴"
        case .vitaminA: return "🥕"
        case .vitaminC: return "🍊"
        case .vitaminD: return "☀️"
        case .bVitamins: return "🔋"
        case .potassium: return "🍌"
        case .magnesium: return "🧘"
        case .zinc: return "🛡️"
        case .omega3: return "🐟"
        case .probiotics: return "🦠"
        }
    }

    /// A short nickname that makes the nutrient memorable.
    var nickname: String {
        switch self {
        case .carbs: return "The Fuel"
        case .protein: return "The Builder"
        case .healthyFats: return "The Brain Butter"
        case .fiber: return "The Tummy Broom"
        case .water: return "The Body River"
        case .iron: return "The Oxygen Truck"
        case .calcium: return "The Bone Brick"
        case .vitaminA: return "The Night-Vision Helper"
        case .vitaminC: return "The Germ Fighter"
        case .vitaminD: return "The Sunshine Vitamin"
        case .bVitamins: return "The Battery Chargers"
        case .potassium: return "The Muscle Messenger"
        case .magnesium: return "The Calm Keeper"
        case .zinc: return "The Shield Maker"
        case .omega3: return "The Brain Builder"
        case .probiotics: return "The Tummy Friends"
        }
    }

    /// Kid-friendly explanation (read aloud by the app).
    var explanation: String {
        switch self {
        case .carbs:
            return "Carbs are your body's fuel. Whole grains like bajra, ragi, rice and wheat give energy that lasts and lasts."
        case .protein:
            return "Protein builds and repairs your muscles. Dal, paneer, beans, eggs and fish are full of it."
        case .healthyFats:
            return "Your brain is made of a lot of fat! A little ghee, nuts, seeds and coconut help it think and remember."
        case .fiber:
            return "Fiber is like a little broom that sweeps your tummy clean. It also makes energy come out slowly, so you don't get tired fast."
        case .water:
            return "Your body is more than half water! Water keeps you cool, helps you think and carries good things everywhere."
        case .iron:
            return "Iron drives tiny trucks in your blood that carry oxygen to your brain and muscles. Without it you feel sleepy and foggy."
        case .calcium:
            return "Calcium is the brick that builds strong bones and teeth. Milk, curd, ragi, til and leafy greens have lots."
        case .vitaminA:
            return "Vitamin A helps your eyes see in the dark and keeps your skin and body strong against germs. Look for orange and green foods!"
        case .vitaminC:
            return "Vitamin C helps your body fight germs and heal scrapes. Amla, lemon, oranges and guava are packed with it."
        case .vitaminD:
            return "Vitamin D helps your bones soak up calcium. Your skin makes it in sunshine, and some foods like eggs, fish and mushrooms have it."
        case .bVitamins:
            return "B vitamins are like chargers that turn your food into energy your brain can use."
        case .potassium:
            return "Potassium carries messages to your muscles so they can stretch and move smoothly. It also keeps the water in your body balanced."
        case .magnesium:
            return "Magnesium helps your muscles relax and your mind feel calm. Seeds, nuts, millets and greens have it."
        case .zinc:
            return "Zinc helps your body build a shield against germs and heal faster."
        case .omega3:
            return "Omega-3 is a special fat that helps your brain grow and focus. Fish, walnuts, flax and chia seeds have it."
        case .probiotics:
            return "Curd, chaas and other fermented foods have friendly bacteria that keep your tummy happy and help fight germs."
        }
    }

    /// The superpowers this nutrient gives. Food benefits are derived from this,
    /// so the "why" is always teachable.
    var benefits: [Benefit] {
        switch self {
        case .carbs: return [.energy]
        case .protein: return [.strength, .stamina]
        case .healthyFats: return [.focus, .energy]
        case .fiber: return [.tummy, .stamina]
        case .water: return [.hydration]
        case .iron: return [.focus, .stamina]
        case .calcium: return [.bones, .strength]
        case .vitaminA: return [.immunity]
        case .vitaminC: return [.immunity]
        case .vitaminD: return [.bones, .immunity]
        case .bVitamins: return [.energy, .focus]
        case .potassium: return [.flexibility, .hydration]
        case .magnesium: return [.flexibility, .calm]
        case .zinc: return [.immunity]
        case .omega3: return [.focus, .calm]
        case .probiotics: return [.tummy, .immunity]
        }
    }
}

/// What the character needs to get out of a tricky situation.
enum Benefit: String, CaseIterable, Codable, Identifiable {
    case focus, energy, stamina, strength, flexibility, bones, immunity, tummy, calm, hydration

    var id: String { rawValue }

    var name: String {
        switch self {
        case .focus: return "Focus"
        case .energy: return "Energy"
        case .stamina: return "Stamina"
        case .strength: return "Strength"
        case .flexibility: return "Bendy Muscles"
        case .bones: return "Strong Bones"
        case .immunity: return "Germ Shield"
        case .tummy: return "Happy Tummy"
        case .calm: return "Calm Mind"
        case .hydration: return "Cool & Watery"
        }
    }

    var emoji: String {
        switch self {
        case .focus: return "🧠"
        case .energy: return "⚡"
        case .stamina: return "🏃"
        case .strength: return "💪"
        case .flexibility: return "🤸"
        case .bones: return "🦴"
        case .immunity: return "🛡️"
        case .tummy: return "🌀"
        case .calm: return "😌"
        case .hydration: return "💧"
        }
    }

    /// Nutrients that grant this benefit (inverse of `Nutrient.benefits`).
    var sources: [Nutrient] {
        Nutrient.allCases.filter { $0.benefits.contains(self) }
    }

    var hint: String {
        let names = sources.prefix(3).map(\.name)
        return "Foods with \(names.joined(separator: " or ")) give \(name)."
    }
}

enum Allergen: String, CaseIterable, Codable, Identifiable {
    case dairy, peanuts, treeNuts, gluten, egg, soy, fish, sesame

    var id: String { rawValue }

    var name: String {
        switch self {
        case .dairy: return "Dairy"
        case .peanuts: return "Peanuts"
        case .treeNuts: return "Tree nuts"
        case .gluten: return "Gluten (wheat)"
        case .egg: return "Egg"
        case .soy: return "Soy"
        case .fish: return "Fish & seafood"
        case .sesame: return "Sesame (til)"
        }
    }

    var emoji: String {
        switch self {
        case .dairy: return "🥛"
        case .peanuts: return "🥜"
        case .treeNuts: return "🌰"
        case .gluten: return "🌾"
        case .egg: return "🥚"
        case .soy: return "🫛"
        case .fish: return "🐟"
        case .sesame: return "⚪️"
        }
    }
}

/// Dietary style of a dish; a family's preference filters what shows up.
/// Ordered: a vegetarian family can eat vegan dishes, and so on.
enum Diet: String, CaseIterable, Codable, Identifiable, Comparable {
    case vegan, vegetarian, eggetarian, nonVegetarian

    var id: String { rawValue }

    var name: String {
        switch self {
        case .vegan: return "Vegan"
        case .vegetarian: return "Vegetarian"
        case .eggetarian: return "Vegetarian + Eggs"
        case .nonVegetarian: return "Everything (incl. meat & fish)"
        }
    }

    private var rank: Int { Diet.allCases.firstIndex(of: self) ?? 0 }

    static func < (lhs: Diet, rhs: Diet) -> Bool { lhs.rank < rhs.rank }
}

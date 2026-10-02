import Foundation

/// Starting points for parents adding their own dish. Parents pick "what kind
/// of dish is it?" and the nutrients are filled in; they can adjust anything.
struct DishTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let nutrients: [Nutrient]
    let tags: Set<FoodTag>
    let diet: Diet
    let allergens: Set<Allergen>
    var isSometimes = false
    let example: String

    static let all: [DishTemplate] = [
        DishTemplate(id: "legume", name: "Beans, lentils or peas", emoji: "🫘",
                     nutrients: [.protein, .fiber, .iron, .magnesium], tags: [.legume], diet: .vegan, allergens: [],
                     example: "Dal, chili beans, lentil soup, hummus"),
        DishTemplate(id: "legume-grain", name: "Beans + a grain together", emoji: "🍛",
                     nutrients: [.protein, .carbs, .fiber, .iron], tags: [.legume, .grain], diet: .vegan, allergens: [],
                     example: "Dal-chawal, rice & beans, khichdi, pasta e fagioli"),
        DishTemplate(id: "grain", name: "Rice, bread or grain", emoji: "🍚",
                     nutrients: [.carbs, .fiber, .bVitamins], tags: [.grain], diet: .vegan, allergens: [],
                     example: "Roti, tortillas, rice, couscous, injera"),
        DishTemplate(id: "porridge", name: "Porridge or cereal", emoji: "🥣",
                     nutrients: [.carbs, .fiber, .magnesium, .iron], tags: [.grain], diet: .vegan, allergens: [],
                     example: "Oats, congee, ugali, upma, kasha"),
        DishTemplate(id: "greens", name: "Leafy greens", emoji: "🥬",
                     nutrients: [.iron, .calcium, .vitaminA, .vitaminC], tags: [.greens], diet: .vegan, allergens: [],
                     example: "Saag, collards, callaloo, bok choy"),
        DishTemplate(id: "vegetables", name: "Mixed vegetables", emoji: "🥕",
                     nutrients: [.fiber, .vitaminA, .vitaminC, .potassium], tags: [], diet: .vegan, allergens: [],
                     example: "Sabzi, ratatouille, stir-fry, roasted veg"),
        DishTemplate(id: "soup", name: "Vegetable soup or stew", emoji: "🍲",
                     nutrients: [.water, .fiber, .vitaminA, .vitaminC], tags: [], diet: .vegan, allergens: [],
                     example: "Minestrone, borscht, rasam, sopa"),
        DishTemplate(id: "yogurt", name: "Yogurt, kefir or buttermilk", emoji: "🥛",
                     nutrients: [.probiotics, .calcium, .protein], tags: [.fermented], diet: .vegetarian, allergens: [.dairy],
                     example: "Curd, raita, lassi, ayran, kefir"),
        DishTemplate(id: "cheese-tofu", name: "Paneer, cheese or tofu", emoji: "🧀",
                     nutrients: [.protein, .calcium], tags: [], diet: .vegetarian, allergens: [.dairy],
                     example: "Paneer bhurji, mapo tofu, ricotta (tofu? switch dairy → soy)"),
        DishTemplate(id: "egg", name: "Egg dish", emoji: "🍳",
                     nutrients: [.protein, .vitaminD, .bVitamins], tags: [], diet: .eggetarian, allergens: [.egg],
                     example: "Omelette, egg curry, shakshuka"),
        DishTemplate(id: "fish", name: "Fish dish", emoji: "🐟",
                     nutrients: [.protein, .omega3, .vitaminD], tags: [], diet: .nonVegetarian, allergens: [.fish],
                     example: "Fish curry, grilled salmon, ceviche"),
        DishTemplate(id: "meat", name: "Chicken or meat dish", emoji: "🍗",
                     nutrients: [.protein, .iron, .zinc, .bVitamins], tags: [], diet: .nonVegetarian, allergens: [],
                     example: "Chicken soup, stew, kebab"),
        DishTemplate(id: "fruit", name: "Fruit", emoji: "🍎",
                     nutrients: [.vitaminC, .fiber, .water], tags: [], diet: .vegan, allergens: [],
                     example: "Mango, papaya, guava, berries"),
        DishTemplate(id: "nuts-seeds", name: "Nuts and seeds", emoji: "🌰",
                     nutrients: [.healthyFats, .magnesium, .protein], tags: [], diet: .vegan, allergens: [.treeNuts],
                     example: "Soaked almonds, walnuts, sesame chikki"),
        DishTemplate(id: "fermented", name: "Pickled or fermented food", emoji: "🫙",
                     nutrients: [.probiotics, .bVitamins], tags: [.fermented], diet: .vegan, allergens: [],
                     example: "Kimchi, sauerkraut, idli, kanji"),
        DishTemplate(id: "treat", name: "Sweet or festival treat", emoji: "🍰",
                     nutrients: [.carbs], tags: [], diet: .vegetarian, allergens: [], isSometimes: true,
                     example: "Laddoo, baklava, birthday cake"),
    ]

    /// A new family dish starting from this template.
    func makeFood() -> Food {
        var food = Food(Self.newID(), "", emoji, nutrients, "", diet: diet, allergens: allergens, sometimes: isSometimes)
        food.tags = tags
        return food
    }

    static func newID() -> String { "family-" + UUID().uuidString.prefix(8).lowercased() }
}

/// Starting points for parents adding a family remedy.
struct RemedyTemplate: Identifiable, Hashable {
    let id: String
    let name: String
    let emoji: String
    let treats: Set<Ailment>
    let steps: [String]
    let caution: String?
    let example: String

    static let all: [RemedyTemplate] = [
        RemedyTemplate(id: "tea", name: "Warm herbal drink or tea", emoji: "🍵", treats: [.soreThroat, .sniffles],
                       steps: ["A grown-up boils water with the herbs or spices.", "Let it cool until it's warm, not hot.", "Sip slowly."],
                       caution: "Hot water! A grown-up makes it.", example: "Kadha, salabat, linden tea, té de canela"),
        RemedyTemplate(id: "gargle", name: "Gargle", emoji: "🧂", treats: [.soreThroat],
                       steps: ["Mix it into a cup of warm water.", "Gargle and spit it out. Don't swallow!"],
                       caution: nil, example: "Salt water, turmeric water"),
        RemedyTemplate(id: "steam", name: "Steam", emoji: "♨️", treats: [.sniffles, .cough],
                       steps: ["A grown-up fills a bowl with hot water and herbs.", "Sit at a safe distance with a towel over your head.", "Breathe slowly for a few minutes."],
                       caution: "Hot water! Only with a grown-up, and never lean too close.", example: "Ajwain steam, eucalyptus leaves"),
        RemedyTemplate(id: "rub", name: "Rub, paste or massage", emoji: "🫙", treats: [.tiredMuscles, .itchyBite],
                       steps: ["A grown-up mixes the paste or warms the oil.", "Check it's not hot.", "Rub gently on the sore spot."],
                       caution: "Test a little on the skin first. Keep away from eyes.", example: "Hing paste, mustard oil, aloe"),
        RemedyTemplate(id: "compress", name: "Warm or cool compress", emoji: "🧊", treats: [.itchyBite, .mildHeadache, .tummyAche],
                       steps: ["Wrap it in a clean cloth.", "Hold it on the spot for a few minutes."],
                       caution: "Never put ice or hot things straight on skin.", example: "Ice cloth, warm water bottle"),
        RemedyTemplate(id: "chew", name: "Spice or seeds to chew", emoji: "🌱", treats: [.tummyAche, .travelTummy],
                       steps: ["Take a small pinch.", "Chew slowly, then sip some water."],
                       caution: nil, example: "Saunf, ajwain, cardamom, ginger candy"),
        RemedyTemplate(id: "sick-food", name: "Gentle food for sick days", emoji: "🥣", treats: [.tummyAche],
                       steps: ["Cook it soft and plain.", "Eat small spoonfuls, slowly."],
                       caution: nil, example: "Khichdi, congee, chicken soup, toast"),
        RemedyTemplate(id: "cooler", name: "Cooling drink", emoji: "🥤", treats: [.tooHot],
                       steps: ["Mix it with cool (not icy) water.", "Add a pinch of salt.", "Sip slowly in the shade."],
                       caution: nil, example: "Chaas, aam panna, coconut water, agua fresca"),
    ]

    func makeRemedy(author: String) -> Remedy {
        var remedy = Remedy(DishTemplate.newID(), "", emoji, treats: treats, "", steps: steps, caution: caution, diet: .vegan)
        remedy.author = author
        return remedy
    }
}

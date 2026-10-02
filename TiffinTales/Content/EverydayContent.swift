import Foundation

/// Staples found in almost every home. Always in the pantry so every mission
/// can be solved, whatever packages a family picks.
enum EverydayContent {
    static let basics = FoodPackage(
        id: "everyday",
        name: "Everyday Pantry",
        emoji: "🧺",
        region: .everyday,
        summary: "Fruits, water, milk, seeds and staples found in most homes.",
        foods: [
            Food("water", "Glass of Water", local: "Paani", "🥛", [.water],
                 "Plain water. The best drink for thinking, playing and cooling down.", diet: .vegan),
            Food("banana", "Banana", local: "Kela", "🍌", [.carbs, .potassium, .bVitamins, .fiber, .magnesium],
                 "Nature's energy bar. Quick fuel plus potassium for muscles.", diet: .vegan),
            Food("apple", "Apple", local: "Seb", "🍎", [.fiber, .vitaminC, .water],
                 "Crunchy, juicy and full of fiber.", diet: .vegan),
            Food("orange", "Orange", local: "Santra", "🍊", [.vitaminC, .water, .fiber],
                 "Juicy segments of vitamin C to fight germs.", diet: .vegan),
            Food("guava", "Guava", local: "Amrood", "🍐", [.vitaminC, .fiber, .potassium],
                 "One guava has more vitamin C than four oranges!", diet: .vegan),
            Food("carrot", "Carrot Sticks", local: "Gajar", "🥕", [.vitaminA, .fiber, .water],
                 "Crunchy orange sticks for sharp eyes.", diet: .vegan),
            Food("cucumber", "Cucumber Slices", local: "Kheera", "🥒", [.water, .potassium],
                 "Cool, crunchy and almost all water.", diet: .vegan),
            Food("milk", "Warm Milk", local: "Doodh", "🥛", [.calcium, .protein, .vitaminD, .bVitamins],
                 "Builds bones and teeth.", allergens: [.dairy]),
            Food("curd", "Bowl of Curd", local: "Dahi", "🍶", [.probiotics, .calcium, .protein],
                 "Cool curd full of friendly tummy bacteria.", allergens: [.dairy]),
            Food("roasted-chana", "Roasted Chana", local: "Bhuna Chana", "🫘", [.protein, .fiber, .iron, .magnesium],
                 "Crunchy roasted gram. A protein-packed pocket snack.", diet: .vegan),
            Food("pumpkin-seeds", "Pumpkin Seeds", "🎃", [.magnesium, .zinc, .iron, .healthyFats],
                 "Tiny green seeds with big calm-and-shield powers.", diet: .vegan),
            Food("dates", "Dates", local: "Khajoor", "🟤", [.carbs, .iron, .potassium, .fiber],
                 "Naturally sweet energy with a little iron.", diet: .vegan),
            Food("palak", "Spinach Greens", local: "Palak", "🥬", [.iron, .vitaminA, .calcium, .magnesium, .vitaminC],
                 "Leafy greens: iron for focus and vitamin A for eyes.", diet: .vegan),
            Food("boiled-egg", "Boiled Egg", local: "Anda", "🥚", [.protein, .vitaminD, .bVitamins, .healthyFats],
                 "A perfect little package of protein.", diet: .eggetarian, allergens: [.egg]),
            Food("sweet-potato", "Roasted Sweet Potato", local: "Shakarkandi", "🍠", [.carbs, .vitaminA, .fiber, .potassium],
                 "Roasted on the tawa or in the coals. Sweet, slow energy.", diet: .vegan),
            Food("makhana", "Roasted Makhana", "⚪️", [.protein, .magnesium, .carbs],
                 "Puffy fox nuts roasted with a pinch of salt. Light and crunchy.", diet: .vegan),
        ],
        isCore: true
    )

    /// "Sometimes foods": yummy on festivals and birthdays, but they don't help
    /// the character in a tricky spot. Shown as gentle distractors.
    static let sometimes: [Food] = [
        Food("chips", "Packet Chips", "🥔", [.carbs],
             "Salty and crunchy, but mostly oil and salt.", diet: .vegan, sometimes: true),
        Food("cola", "Fizzy Cola", "🥤", [.carbs],
             "Lots of sugar bubbles. A quick zoom, then a big crash.", diet: .vegan, sometimes: true),
        Food("candy", "Candy", "🍬", [.carbs],
             "Sticky sugar that stays on your teeth.", diet: .vegan, sometimes: true),
        Food("instant-noodles", "Instant Noodles", "🍜", [.carbs],
             "Quick to cook, but low on the good stuff and high in salt.", allergens: [.gluten], sometimes: true),
        Food("cream-biscuits", "Cream Biscuits", "🍪", [.carbs],
             "Sweet and tasty, but mostly sugar and flour.", allergens: [.gluten, .dairy], sometimes: true),
        Food("ice-cream", "Ice Cream", "🍨", [.carbs],
             "A cold treat for special days.", allergens: [.dairy], sometimes: true),
        Food("jalebi", "Jalebi", "🥨", [.carbs],
             "A festival favourite. Fried swirls soaked in sugar syrup.", allergens: [.gluten], sometimes: true),
        Food("samosa", "Samosa", "🥟", [.carbs],
             "Deep-fried and delicious. Perfect for a party, not for a mission.", diet: .vegan, allergens: [.gluten], sometimes: true),
        Food("cake", "Birthday Cake", "🎂", [.carbs],
             "For birthdays! Lots of sugar and butter.", diet: .eggetarian, allergens: [.gluten, .dairy, .egg], sometimes: true),
        Food("peanut-chikki", "Peanut Chikki", "🥜", [.carbs, .protein],
             "Jaggery and peanut crunch. Yummy, but very sticky and sweet.", diet: .vegan, allergens: [.peanuts], sometimes: true),
    ]
}

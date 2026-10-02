import Foundation

/// Home-cooking packages from kitchens around the world.
enum WorldPackages {
    static let all: [FoodPackage] = [
        japanese, chinese, korean, mexican, levantine, italian, westAfrican, ethiopian, homestyleWestern,
    ]

    static let japanese = FoodPackage(
        id: "japanese", name: "Japanese Home Kitchen", emoji: "🍙", region: .world,
        summary: "Ichiju-sansai: rice, miso soup and small side dishes.",
        foods: [
            Food("miso-soup", "Miso Soup with Tofu", "🍵", [.probiotics, .protein, .water],
                 "Fermented soybean soup with tofu and seaweed.", diet: .vegan, allergens: [.soy]),
            Food("onigiri", "Onigiri", "🍙", [.carbs, .fiber],
                 "Rice balls wrapped in nori seaweed.", diet: .vegan),
            Food("grilled-salmon", "Grilled Salmon", "🐟", [.protein, .omega3, .vitaminD],
                 "Simply salted and grilled.", diet: .nonVegetarian, allergens: [.fish]),
            Food("edamame", "Edamame", "🫛", [.protein, .fiber, .bVitamins, .magnesium],
                 "Young soybeans, popped straight from the pod.", diet: .vegan, allergens: [.soy]),
            Food("tamagoyaki", "Tamagoyaki", "🥚", [.protein, .vitaminD, .bVitamins],
                 "Rolled omelette, sliced for the bento box.", diet: .eggetarian, allergens: [.egg]),
            Food("goma-ae", "Spinach Goma-ae", "🥬", [.iron, .calcium, .vitaminA, .magnesium],
                 "Blanched spinach with a sesame dressing.", diet: .vegan, allergens: [.sesame, .soy]),
            Food("mochi", "Mochi Sweets", "🍡", [.carbs],
                 "Chewy rice-cake sweets for New Year. Sometimes!", diet: .vegan, sometimes: true),
        ]
    )

    static let chinese = FoodPackage(
        id: "chinese", name: "Chinese Home Kitchen", emoji: "🥢", region: .world,
        summary: "Jiachang cai: congee, steamed fish, tomato-egg and greens.",
        foods: [
            Food("congee", "Congee", "🥣", [.water, .carbs],
                 "Silky rice porridge, gentle on any tummy.", diet: .vegan),
            Food("steamed-fish", "Ginger-Scallion Steamed Fish", "🐟", [.protein, .omega3, .vitaminD],
                 "Whole fish steamed with ginger and spring onion.", diet: .nonVegetarian, allergens: [.fish, .soy]),
            Food("bok-choy", "Garlic Bok Choy", "🥬", [.calcium, .vitaminA, .vitaminC, .fiber],
                 "Quick stir-fried baby greens.", diet: .vegan),
            Food("tomato-egg", "Tomato Egg Stir-Fry", "🍅", [.protein, .vitaminC, .vitaminA],
                 "Fluffy eggs with sweet-sour tomatoes, every kid's favourite.", diet: .eggetarian, allergens: [.egg]),
            Food("mapo-tofu-mild", "Mild Tofu & Veggies", "🧈", [.protein, .calcium, .iron],
                 "Soft tofu braised with mushrooms and peas.", diet: .vegan, allergens: [.soy]),
            Food("jiaozi", "Steamed Dumplings", "🥟", [.protein, .carbs, .fiber],
                 "Pleated dumplings filled with cabbage and pork or mushrooms.", diet: .nonVegetarian, allergens: [.gluten, .soy]),
            Food("mooncake", "Mooncake", "🥮", [.carbs],
                 "Mid-Autumn Festival treat. Rich and sweet.", diet: .eggetarian, allergens: [.gluten, .egg], sometimes: true),
        ]
    )

    static let korean = FoodPackage(
        id: "korean", name: "Korean Home Kitchen", emoji: "🍚", region: .world,
        summary: "Bap, guk and banchan: rice, soup and lots of little sides.",
        foods: [
            Food("bibimbap", "Bibimbap", "🍲", [.fiber, .vitaminA, .protein, .carbs, .iron],
                 "Rice topped with colourful vegetables and an egg.", diet: .eggetarian, allergens: [.egg, .sesame, .soy]),
            Food("kimchi", "Mild Kimchi", "🥬", [.probiotics, .vitaminC, .fiber],
                 "Fermented cabbage, full of good bacteria.", diet: .nonVegetarian, allergens: [.fish]),
            Food("doenjang", "Doenjang Jjigae", "🍲", [.protein, .probiotics, .fiber],
                 "Soybean-paste stew with tofu, zucchini and potato.", diet: .vegan, allergens: [.soy]),
            Food("gyeran-jjim", "Gyeran Jjim", "🥚", [.protein, .vitaminD, .bVitamins],
                 "Fluffy steamed egg in a stone pot.", diet: .eggetarian, allergens: [.egg]),
            Food("japchae", "Japchae", "🍜", [.carbs, .vitaminA, .fiber],
                 "Sweet-potato glass noodles with spinach and carrots.", diet: .vegan, allergens: [.sesame, .soy]),
            Food("tteok", "Honey Tteok", "🍡", [.carbs],
                 "Sweet rice cakes for celebrations.", diet: .vegan, sometimes: true),
        ]
    )

    static let mexican = FoodPackage(
        id: "mexican", name: "Mexican Cocina", emoji: "🌮", region: .world,
        summary: "Beans, corn, squash and salsa from abuela's stove.",
        foods: [
            Food("frijoles", "Frijoles de Olla", "🫘", [.protein, .fiber, .iron, .magnesium],
                 "Pinto beans simmered slowly in a clay pot.", diet: .vegan),
            Food("corn-tortilla", "Corn Tortillas", "🫓", [.carbs, .calcium, .fiber],
                 "Nixtamal corn tortillas. The lime they're made with adds calcium!", diet: .vegan),
            Food("guacamole", "Guacamole", "🥑", [.healthyFats, .potassium, .fiber, .vitaminC],
                 "Mashed avocado with lime and tomato.", diet: .vegan),
            Food("sopa-lentejas", "Sopa de Lentejas", "🍲", [.protein, .iron, .fiber, .vitaminA],
                 "Lentil soup with carrots and tomatoes.", diet: .vegan),
            Food("calabacitas", "Calabacitas", "🎃", [.vitaminC, .fiber, .vitaminA, .water],
                 "Sautéed squash, corn and tomato.", diet: .vegan),
            Food("huevos-rancheros", "Huevos Rancheros", "🍳", [.protein, .vitaminD, .carbs, .vitaminC],
                 "Eggs on tortillas with fresh salsa.", diet: .eggetarian, allergens: [.egg]),
            Food("churros", "Churros", "🥖", [.carbs],
                 "Fried dough with cinnamon sugar. A fiesta treat!", diet: .eggetarian, allergens: [.gluten, .egg], sometimes: true),
        ]
    )

    static let levantine = FoodPackage(
        id: "levantine", name: "Middle Eastern Kitchen", emoji: "🫒", region: .world,
        summary: "Mezze tables of the Levant: hummus, tabbouleh, lentil soup and labneh.",
        foods: [
            Food("hummus", "Hummus & Veggies", "🧆", [.protein, .fiber, .healthyFats, .iron],
                 "Creamy chickpeas with tahini and olive oil.", diet: .vegan, allergens: [.sesame]),
            Food("tabbouleh", "Tabbouleh", "🥗", [.vitaminC, .iron, .fiber, .vitaminA],
                 "Parsley salad with bulgur, tomato and lemon.", diet: .vegan, allergens: [.gluten]),
            Food("shorbat-adas", "Shorbat Adas", "🍲", [.protein, .iron, .fiber, .water],
                 "Red lentil soup with cumin and a squeeze of lemon.", diet: .vegan),
            Food("labneh", "Labneh & Za'atar", "🧀", [.probiotics, .calcium, .protein],
                 "Thick strained yogurt with herbs and olive oil.", allergens: [.dairy, .sesame]),
            Food("shakshuka", "Shakshuka", "🍳", [.protein, .vitaminC, .vitaminA, .vitaminD],
                 "Eggs poached in tomato and pepper sauce.", diet: .eggetarian, allergens: [.egg]),
            Food("dates-walnuts", "Dates & Walnuts", "🌰", [.carbs, .omega3, .iron, .magnesium],
                 "Sweet dates stuffed with walnuts.", diet: .vegan, allergens: [.treeNuts]),
            Food("baklava", "Baklava", "🥮", [.carbs],
                 "Layers of pastry, nuts and syrup for Eid. Sometimes!", allergens: [.gluten, .treeNuts, .dairy], sometimes: true),
        ]
    )

    static let italian = FoodPackage(
        id: "italian", name: "Italian Nonna's Kitchen", emoji: "🍅", region: .world,
        summary: "Cucina povera: minestrone, beans and pasta, greens and frittata.",
        foods: [
            Food("minestrone", "Minestrone", "🍲", [.fiber, .vitaminA, .protein, .water],
                 "Vegetable and bean soup that changes with the seasons.", diet: .vegan),
            Food("pasta-fagioli", "Pasta e Fagioli", "🍝", [.protein, .fiber, .carbs, .iron],
                 "Pasta and beans in a tomato broth.", diet: .vegan, allergens: [.gluten]),
            Food("spinach-frittata", "Spinach Frittata", "🥚", [.protein, .iron, .vitaminA, .vitaminD],
                 "Baked egg pie full of greens.", diet: .eggetarian, allergens: [.egg, .dairy]),
            Food("ricotta-toast", "Ricotta & Tomato Toast", "🍞", [.calcium, .protein, .vitaminC, .carbs],
                 "Fresh ricotta on whole-grain bread with tomatoes.", allergens: [.dairy, .gluten]),
            Food("sardines", "Sardines on Toast", "🐟", [.omega3, .calcium, .protein, .vitaminD],
                 "Tiny fish with big brain power.", diet: .nonVegetarian, allergens: [.fish, .gluten]),
            Food("gelato", "Gelato", "🍦", [.carbs],
                 "Creamy and sweet, for warm summer evenings.", allergens: [.dairy], sometimes: true),
        ]
    )

    static let westAfrican = FoodPackage(
        id: "west-african", name: "West African Kitchen", emoji: "🌍", region: .world,
        summary: "Red-red, moi moi, egusi and jollof from Ghana and Nigeria.",
        foods: [
            Food("red-red", "Red-Red & Plantain", "🍌", [.protein, .fiber, .vitaminA, .potassium],
                 "Black-eyed pea stew with ripe plantains.", diet: .vegan),
            Food("moi-moi", "Moi Moi", "🫘", [.protein, .fiber, .iron],
                 "Steamed bean pudding with peppers.", diet: .vegan),
            Food("egusi", "Egusi Soup", "🥬", [.protein, .iron, .vitaminA, .healthyFats],
                 "Ground melon seeds cooked with spinach.", diet: .nonVegetarian, allergens: [.fish]),
            Food("jollof", "Veggie Jollof Rice", "🍚", [.carbs, .vitaminA, .vitaminC],
                 "Tomato-pepper rice, the star of every party.", diet: .vegan),
            Food("groundnut-soup", "Groundnut Soup", "🥜", [.protein, .healthyFats, .magnesium],
                 "Creamy peanut soup with tomatoes.", diet: .nonVegetarian, allergens: [.peanuts]),
            Food("puff-puff", "Puff-Puff", "🟤", [.carbs],
                 "Sweet fried dough balls. Sometimes treat!", diet: .vegan, allergens: [.gluten], sometimes: true),
        ]
    )

    static let ethiopian = FoodPackage(
        id: "ethiopian", name: "Ethiopian Kitchen", emoji: "🫓", region: .world,
        summary: "Injera with misir wat, shiro and gomen, shared from one big plate.",
        foods: [
            Food("injera", "Teff Injera", "🫓", [.iron, .calcium, .carbs, .fiber, .probiotics],
                 "Spongy fermented flatbread of teff, the tiniest grain in the world.", diet: .vegan),
            Food("misir-wat", "Misir Wat", "🍲", [.protein, .iron, .fiber],
                 "Red lentils in berbere spice.", diet: .vegan),
            Food("shiro", "Shiro", "🥣", [.protein, .fiber, .magnesium],
                 "Smooth chickpea stew.", diet: .vegan),
            Food("gomen", "Gomen", "🥬", [.calcium, .vitaminA, .vitaminC, .iron],
                 "Collard greens cooked with garlic and ginger.", diet: .vegan),
            Food("doro-wat", "Doro Wat", "🍗", [.protein, .zinc, .vitaminD],
                 "Festive chicken stew with a boiled egg.", diet: .nonVegetarian, allergens: [.egg, .dairy]),
        ]
    )

    static let homestyleWestern = FoodPackage(
        id: "western", name: "American & British Home", emoji: "🥪", region: .world,
        summary: "Oatmeal, beans on toast, soups and simple lunchbox food.",
        foods: [
            Food("oatmeal-berries", "Oatmeal with Berries", "🥣", [.fiber, .carbs, .magnesium, .vitaminC, .iron],
                 "Warm oats topped with berries.", diet: .vegan),
            Food("beans-toast", "Beans on Toast", "🍞", [.protein, .fiber, .iron, .carbs],
                 "Baked beans on whole-grain toast.", diet: .vegan, allergens: [.gluten]),
            Food("pb-sandwich", "Peanut Butter & Banana Sandwich", "🥪", [.protein, .healthyFats, .potassium, .carbs],
                 "Whole-wheat bread with peanut butter and banana slices.", diet: .vegan, allergens: [.peanuts, .gluten]),
            Food("scrambled-eggs", "Scrambled Eggs", "🍳", [.protein, .vitaminD, .bVitamins],
                 "Soft scrambled eggs.", diet: .eggetarian, allergens: [.egg, .dairy]),
            Food("baked-potato", "Baked Potato & Broccoli", "🥔", [.carbs, .potassium, .vitaminC, .fiber],
                 "Fluffy jacket potato with steamed broccoli.", diet: .vegan),
            Food("chicken-soup", "Chicken Vegetable Soup", "🍲", [.protein, .water, .vitaminA, .zinc],
                 "Warm broth with chicken, carrots and celery.", diet: .nonVegetarian),
            Food("donut", "Glazed Donut", "🍩", [.carbs],
                 "Sugary and fried. A sometimes treat!", diet: .eggetarian, allergens: [.gluten, .egg, .dairy], sometimes: true),
        ]
    )
}

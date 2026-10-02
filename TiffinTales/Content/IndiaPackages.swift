import Foundation

/// Home-kitchen packages from across India. Each region gets its everyday
/// dishes (what families actually cook on a Tuesday), plus one or two
/// festival "sometimes" treats so kids learn the difference.
enum IndiaPackages {
    static let all: [FoodPackage] = [
        baniya, jain, rajasthani, gujarati, odia, bengali, bihari, assamese,
        punjabi, kashmiri, sindhi, maharashtrian, tamil, kerala, andhra, kannada,
    ]

    static let baniya = FoodPackage(
        id: "baniya", name: "Baniya Rasoi", emoji: "🪔", region: .india,
        summary: "Simple, satvik vegetarian food from Agarwal & Baniya homes of North India: dal, seasonal sabzi, chilla and dalia.",
        foods: [
            Food("arhar-dal", "Arhar Dal & Rice", local: "Dal Chawal", "🍛", [.protein, .carbs, .fiber, .iron, .bVitamins],
                 "Yellow toor dal with a jeera-hing tadka, served on soft rice.", diet: .vegan),
            Food("lauki-chana", "Lauki Chana Dal", "🥒", [.water, .protein, .fiber, .potassium],
                 "Bottle gourd cooked with chana dal. Light, cooling and filling.", diet: .vegan),
            Food("moong-chilla", "Moong Dal Chilla", "🥞", [.protein, .iron, .fiber, .bVitamins],
                 "Savoury pancakes of ground moong dal, with ginger and coriander.", diet: .vegan),
            Food("veg-dalia", "Vegetable Dalia", "🥣", [.carbs, .fiber, .iron, .magnesium, .vitaminA],
                 "Broken wheat cooked soft with peas and carrots.", diet: .vegan, allergens: [.gluten]),
            Food("kaddu-sabzi", "Khatta-Meetha Kaddu", local: "Kaddu ki Sabzi", "🎃", [.vitaminA, .fiber, .potassium, .carbs],
                 "Sweet-and-sour pumpkin with methi seeds and a touch of gur.", diet: .vegan),
            Food("aloo-methi-roti", "Aloo Methi & Phulka", "🫓", [.carbs, .iron, .fiber, .vitaminC],
                 "Potatoes tossed with fresh fenugreek leaves, with hot phulkas.", diet: .vegan, allergens: [.gluten]),
            Food("moong-sprouts", "Sprouted Moong Chaat", "🌱", [.protein, .vitaminC, .fiber, .iron],
                 "Sprouts with tomato, cucumber, lemon and chaat masala.", diet: .vegan),
            Food("bathua-raita", "Bathua Raita", "🥗", [.probiotics, .calcium, .iron, .vitaminA],
                 "Winter greens folded into cool curd.", allergens: [.dairy]),
            Food("moong-halwa", "Moong Dal Halwa", "🍯", [.carbs],
                 "A rich winter-wedding sweet made with lots of ghee and sugar.", allergens: [.dairy], sometimes: true),
        ]
    )

    static let jain = FoodPackage(
        id: "jain", name: "Jain Rasoi", emoji: "🕊️", region: .india,
        summary: "No onion, garlic or root vegetables. Clever, flavourful cooking from Jain homes.",
        foods: [
            Food("dal-dhokli", "Dal Dhokli", "🍲", [.protein, .carbs, .fiber, .iron],
                 "Wheat dumplings simmered in sweet-sour toor dal.", diet: .vegan, allergens: [.gluten, .peanuts]),
            Food("kacha-kela", "Kacha Kela Sabzi", "🍌", [.fiber, .potassium, .carbs, .vitaminC],
                 "Raw banana cooked with ajwain and hing instead of potatoes.", diet: .vegan),
            Food("moong-khichdi", "Moong Khichdi", "🍚", [.protein, .carbs, .fiber, .magnesium],
                 "Rice and moong dal cooked soft with a ghee-jeera tadka.", diet: .vegan),
            Food("tindora", "Tindora Sabzi", "🥒", [.fiber, .vitaminC, .water],
                 "Crunchy ivy gourd stir-fry.", diet: .vegan),
            Food("papad-sabzi", "Gatte & Papad Sabzi", "🟡", [.protein, .iron, .calcium],
                 "Besan dumplings and papad in a tangy curd gravy.", allergens: [.dairy]),
            Food("rajgira-thepla", "Rajgira Thepla", "🫓", [.protein, .calcium, .iron, .magnesium],
                 "Amaranth flatbreads, a fasting-day favourite packed with minerals.", diet: .vegan),
            Food("jain-chaas", "Masala Chaas", "🥛", [.probiotics, .water, .calcium],
                 "Thin, salted buttermilk with roasted jeera.", allergens: [.dairy]),
        ]
    )

    static let rajasthani = FoodPackage(
        id: "rajasthani", name: "Rajasthani Rasoi", emoji: "🐪", region: .india,
        summary: "Desert-smart cooking: millets, dried beans and berries, and plenty of buttermilk.",
        foods: [
            Food("bajra-roti", "Bajra Roti with Gur", "🫓", [.carbs, .iron, .magnesium, .fiber],
                 "Thick pearl-millet roti with a lump of jaggery. Warming winter fuel.", diet: .vegan),
            Food("ker-sangri", "Ker Sangri", "🌿", [.fiber, .calcium, .iron, .protein],
                 "Desert beans and tiny berries, dried and cooked with spices.", diet: .vegan),
            Food("raab", "Bajra Raab", local: "Raab", "🥣", [.carbs, .magnesium, .fiber, .calcium, .water],
                 "A warm, thin porridge of bajra and buttermilk.", allergens: [.dairy]),
            Food("gatte", "Gatte ki Sabzi", "🟡", [.protein, .calcium, .iron],
                 "Steamed besan dumplings in a yogurt curry.", allergens: [.dairy]),
            Food("panchkuta", "Panchkuta", "🫛", [.fiber, .iron, .calcium, .magnesium],
                 "Five desert foods, ker, sangri, kumat, gunda and amchur, cooked together.", diet: .vegan),
            Food("missi-roti", "Missi Roti", "🫓", [.protein, .fiber, .iron, .carbs],
                 "Flatbread of besan and wheat with onion and ajwain.", diet: .vegan, allergens: [.gluten]),
            Food("dal-baati", "Dal Baati", "🍘", [.protein, .carbs, .fiber],
                 "Baked wheat balls with panchmel dal. Hearty farm food.", allergens: [.gluten, .dairy]),
            Food("rajasthani-chaach", "Chaach", "🥛", [.probiotics, .water, .calcium],
                 "Cool spiced buttermilk, the desert's best drink.", allergens: [.dairy]),
            Food("churma", "Churma", "🍯", [.carbs],
                 "Crumbled baati with ghee and sugar. Festive and very sweet!", allergens: [.gluten, .dairy], sometimes: true),
            Food("mirchi-bada", "Mirchi Bada", "🌶️", [.carbs],
                 "Big fried chilli fritters from Jodhpur. A spicy sometimes snack.", diet: .vegan, sometimes: true),
        ]
    )

    static let gujarati = FoodPackage(
        id: "gujarati", name: "Gujarati Rasoi", emoji: "🪁", region: .india,
        summary: "Steamed, fermented and sweet-sour: dhokla, thepla, handvo and the full dal-bhaat-rotli-shaak.",
        foods: [
            Food("methi-thepla", "Methi Thepla", "🫓", [.carbs, .iron, .fiber, .vitaminA],
                 "Soft spiced flatbreads with fenugreek leaves. Great for travel!", diet: .vegan, allergens: [.gluten]),
            Food("dhokla", "Khaman Dhokla", "🧽", [.protein, .bVitamins, .carbs],
                 "Fluffy steamed besan cake. Fermenting adds B vitamins.", diet: .vegan),
            Food("khandvi", "Khandvi", "🌀", [.protein, .calcium],
                 "Silky rolls of besan cooked in buttermilk.", allergens: [.dairy, .sesame]),
            Food("handvo", "Handvo", "🍰", [.protein, .fiber, .vitaminA, .bVitamins],
                 "Savoury baked lentil-rice cake with lauki and carrots, topped with til.", allergens: [.dairy, .sesame]),
            Food("undhiyu", "Undhiyu", "🫕", [.fiber, .vitaminA, .potassium, .iron],
                 "Winter mixed vegetables slow-cooked with methi muthiya.", diet: .vegan, allergens: [.gluten]),
            Food("khichdi-kadhi", "Khichdi Kadhi", "🍚", [.protein, .carbs, .calcium, .probiotics],
                 "Comforting rice-dal khichdi with sweet-tangy Gujarati kadhi.", allergens: [.dairy]),
            Food("muthiya", "Lauki Muthiya", "🥟", [.fiber, .iron, .carbs, .water],
                 "Steamed dumplings of bottle gourd and flour.", diet: .vegan, allergens: [.gluten, .sesame]),
            Food("gujarati-thali", "Dal-Bhaat-Rotli-Shaak", "🍱", [.protein, .carbs, .fiber, .iron, .vitaminC],
                 "The everyday plate: sweet-sour dal, rice, rotli and a seasonal shaak.", diet: .vegan, allergens: [.gluten]),
            Food("fafda-jalebi", "Fafda Jalebi", "🥨", [.carbs],
                 "Dussehra-morning special! Fried and sweet, so it's for sometimes.", diet: .vegan, allergens: [.gluten], sometimes: true),
        ]
    )

    static let odia = FoodPackage(
        id: "odia", name: "Odia Rasoi", emoji: "🛕", region: .india,
        summary: "Gentle, mustard-scented food from Odisha: dalma, santula, pakhala and pitha.",
        foods: [
            Food("dalma", "Dalma", "🍲", [.protein, .fiber, .vitaminA, .potassium, .iron],
                 "Toor dal cooked with pumpkin, raw papaya and banana. Puri's temple favourite.", diet: .vegan),
            Food("pakhala", "Pakhala Bhata", "🍚", [.water, .probiotics, .carbs, .potassium],
                 "Rice soaked in water overnight. Cool, fermented summer food.", diet: .vegan),
            Food("santula", "Santula", "🥘", [.vitaminA, .fiber, .water, .potassium],
                 "Lightly spiced boiled vegetables. Easy on the tummy.", diet: .vegan),
            Food("saga-bhaja", "Saga Bhaja", "🥬", [.iron, .calcium, .vitaminA, .magnesium],
                 "Leafy greens stir-fried with garlic and dry chilli.", diet: .vegan),
            Food("chakuli-pitha", "Chakuli Pitha", "🥞", [.carbs, .protein, .probiotics],
                 "Thin fermented rice-and-urad pancakes.", diet: .vegan),
            Food("ghanta", "Ghanta Tarkari", "🫕", [.fiber, .protein, .vitaminA, .iron],
                 "A mixed-vegetable and lentil curry made for festivals and family days.", diet: .vegan),
            Food("dahi-baigana", "Dahi Baigana", "🍆", [.probiotics, .calcium, .fiber],
                 "Fried brinjal in tempered curd.", allergens: [.dairy]),
            Food("macha-besara", "Macha Besara", "🐟", [.protein, .omega3, .vitaminD],
                 "Fish cooked in mustard paste.", diet: .nonVegetarian, allergens: [.fish]),
            Food("chhena-poda", "Chhena Poda", "🍮", [.carbs],
                 "Baked cottage-cheese sweet. Delicious and very sugary!", allergens: [.dairy], sometimes: true),
        ]
    )

    static let bengali = FoodPackage(
        id: "bengali", name: "Bengali Rannaghor", emoji: "🐟", region: .india,
        summary: "Bitter-to-sweet courses: shukto, shaak, moong dal, macher jhol and doi.",
        foods: [
            Food("shukto", "Shukto", "🥗", [.fiber, .vitaminA, .potassium, .vitaminC],
                 "A gently bitter mixed-vegetable starter that wakes up digestion.", diet: .vegan),
            Food("macher-jhol", "Macher Jhol & Bhaat", "🐟", [.protein, .omega3, .vitaminD, .carbs],
                 "Light fish curry with potatoes, and rice.", diet: .nonVegetarian, allergens: [.fish]),
            Food("bhaja-moong", "Bhaja Moong Dal", "🍛", [.protein, .iron, .fiber],
                 "Roasted moong dal, nutty and golden.", diet: .vegan),
            Food("shaak-bhaja", "Shaak Bhaja", "🥬", [.iron, .calcium, .vitaminA, .vitaminC],
                 "Greens like lal shaak or pui shaak fried with kalo jeere.", diet: .vegan),
            Food("chhana-gur", "Chhana with Gur", "🧀", [.protein, .calcium, .bVitamins],
                 "Fresh soft cheese with a little date-palm jaggery.", allergens: [.dairy]),
            Food("jhal-muri", "Jhal Muri", "🍿", [.carbs, .protein, .fiber, .vitaminC],
                 "Puffed rice tossed with chana, onion, cucumber and mustard oil.", diet: .vegan, allergens: [.peanuts]),
            Food("aloo-posto", "Aloo Posto", "🥔", [.calcium, .magnesium, .healthyFats, .carbs],
                 "Potatoes in creamy poppy-seed paste.", diet: .vegan),
            Food("dim-dalna", "Dimer Dalna", "🥚", [.protein, .vitaminD, .bVitamins],
                 "Egg and potato curry.", diet: .eggetarian, allergens: [.egg]),
            Food("rosogolla", "Rosogolla", "⚪️", [.carbs],
                 "Spongy sweets in syrup. A sometimes joy!", allergens: [.dairy], sometimes: true),
        ]
    )

    static let bihari = FoodPackage(
        id: "bihari", name: "Bihari Rasoi", emoji: "🌾", region: .india,
        summary: "The power of sattu: litti chokha, ghugni and cooling sattu drinks.",
        foods: [
            Food("litti-chokha", "Litti Chokha", "🧆", [.protein, .fiber, .iron, .vitaminC],
                 "Wheat balls stuffed with sattu, with smoky mashed brinjal-tomato.", diet: .vegan, allergens: [.gluten]),
            Food("sattu-drink", "Sattu Sharbat", "🥤", [.protein, .iron, .fiber, .water],
                 "Roasted gram flour stirred into water with lemon and salt.", diet: .vegan),
            Food("ghugni", "Ghugni", "🫘", [.protein, .fiber, .iron],
                 "Spiced black chana or dried peas.", diet: .vegan),
            Food("chura-dahi", "Chura Dahi", "🍚", [.probiotics, .carbs, .calcium, .iron],
                 "Flattened rice with curd. A Makar Sankranti classic.", allergens: [.dairy]),
            Food("dal-pitha", "Dal Pitha", "🥟", [.carbs, .protein, .fiber],
                 "Steamed rice dumplings stuffed with spiced chana dal.", diet: .vegan),
            Food("thekua", "Thekua", "🍪", [.carbs],
                 "Crunchy fried wheat-and-jaggery cookies made for Chhath.", allergens: [.gluten], sometimes: true),
        ]
    )

    static let assamese = FoodPackage(
        id: "assamese", name: "Assamese Rasoi", emoji: "🍃", region: .india,
        summary: "Light, tangy dishes from Assam: masor tenga, khar and pitika.",
        foods: [
            Food("masor-tenga", "Masor Tenga", "🐠", [.protein, .omega3, .vitaminC],
                 "Sour fish curry with tomatoes or elephant apple.", diet: .nonVegetarian, allergens: [.fish]),
            Food("khar", "Papaya Khar", "🥘", [.fiber, .potassium, .vitaminA],
                 "Raw papaya and dal cooked with traditional alkaline khar.", diet: .vegan),
            Food("aloo-pitika", "Aloo Pitika", "🥔", [.carbs, .potassium, .vitaminC],
                 "Mashed potato with mustard oil, onion and green chilli.", diet: .vegan),
            Food("jolpan", "Jolpan", "🥣", [.carbs, .probiotics, .calcium],
                 "Flattened rice with curd and a little jaggery for breakfast.", allergens: [.dairy]),
            Food("lai-xaak", "Lai Xaak", "🥬", [.iron, .calcium, .vitaminA, .vitaminC],
                 "Mustard greens, lightly cooked.", diet: .vegan),
            Food("til-pitha", "Til Pitha", "🌯", [.carbs],
                 "Sticky rice rolls filled with sesame and jaggery for Bihu.", diet: .vegan, allergens: [.sesame], sometimes: true),
        ]
    )

    static let punjabi = FoodPackage(
        id: "punjabi", name: "Punjabi Rasoi", emoji: "🌻", region: .india,
        summary: "Hearty farmhouse food: saag-makki, rajma-chawal, lassi and paneer.",
        foods: [
            Food("saag-makki", "Sarson da Saag & Makki di Roti", "🥬", [.iron, .calcium, .vitaminA, .vitaminC, .fiber, .carbs],
                 "Slow-cooked mustard greens with maize flatbread and a little makkhan.", allergens: [.dairy]),
            Food("rajma-chawal", "Rajma Chawal", "🫘", [.protein, .iron, .fiber, .carbs],
                 "Kidney beans in onion-tomato gravy with rice. A Sunday favourite.", diet: .vegan),
            Food("chole-roti", "Chole & Roti", "🧆", [.protein, .fiber, .iron, .carbs],
                 "Spiced chickpeas with whole-wheat roti.", diet: .vegan, allergens: [.gluten]),
            Food("lassi", "Plain Lassi", "🥛", [.probiotics, .calcium, .protein, .water],
                 "Churned curd drink. Ask for less sugar!", allergens: [.dairy]),
            Food("paneer-bhurji", "Paneer Bhurji", "🧀", [.protein, .calcium, .vitaminD],
                 "Scrambled paneer with tomatoes and capsicum.", allergens: [.dairy]),
            Food("aloo-paratha", "Aloo Paratha with Dahi", "🫓", [.carbs, .probiotics, .calcium, .potassium],
                 "Stuffed paratha with a bowl of curd.", allergens: [.gluten, .dairy]),
            Food("kali-dal", "Dal Makhani (Maa ki Dal)", "🍲", [.protein, .iron, .fiber, .zinc],
                 "Whole urad and rajma cooked low and slow overnight.", allergens: [.dairy]),
            Food("chicken-curry", "Home Chicken Curry", "🍗", [.protein, .zinc, .bVitamins],
                 "Everyday chicken curry with onion-tomato masala.", diet: .nonVegetarian),
            Food("pinni", "Atta Pinni", "🟤", [.carbs],
                 "Winter ladoos of wheat, ghee and sugar. Sometimes treats.", allergens: [.gluten, .dairy, .treeNuts], sometimes: true),
        ]
    )

    static let kashmiri = FoodPackage(
        id: "kashmiri", name: "Kashmiri Kitchen", emoji: "🏔️", region: .india,
        summary: "Warming valley food: haak saag, nadru, rajma and walnuts.",
        foods: [
            Food("haak", "Haak Saag", "🥬", [.iron, .calcium, .vitaminA, .vitaminC],
                 "Collard greens simmered simply with mustard oil and hing.", diet: .vegan),
            Food("nadru-yakhni", "Nadru Yakhni", "🪷", [.fiber, .vitaminC, .potassium, .probiotics],
                 "Lotus stem in a gentle yogurt gravy with fennel.", allergens: [.dairy]),
            Food("kashmiri-rajma", "Kashmiri Rajma & Rice", "🫘", [.protein, .iron, .fiber, .carbs],
                 "Small, sweet Bhaderwahi rajma cooked with rice.", diet: .vegan),
            Food("walnuts", "Kashmiri Walnuts", "🌰", [.omega3, .healthyFats, .magnesium],
                 "Brain-shaped nuts that really are brain food!", diet: .vegan, allergens: [.treeNuts]),
            Food("monji-haak", "Monji Haak", "🥬", [.fiber, .vitaminC, .potassium],
                 "Kohlrabi with its leaves, cooked till soft.", diet: .vegan),
            Food("kashmiri-mutton", "Rogan Josh", "🍖", [.protein, .iron, .zinc, .bVitamins],
                 "Slow-cooked mutton with fennel and dry ginger.", diet: .nonVegetarian, allergens: [.dairy]),
        ]
    )

    static let sindhi = FoodPackage(
        id: "sindhi", name: "Sindhi Rasoi", emoji: "⛵", region: .india,
        summary: "Comforting Sindhi home food: sai bhaji, koki and veggie-loaded kadhi.",
        foods: [
            Food("sai-bhaji", "Sai Bhaji & Rice", "🥬", [.iron, .protein, .fiber, .vitaminA],
                 "Spinach, dill and chana dal cooked with vegetables.", diet: .vegan),
            Food("sindhi-kadhi", "Sindhi Kadhi", "🍲", [.fiber, .vitaminA, .potassium, .protein, .vitaminC],
                 "Tangy besan and tamarind curry full of drumsticks and vegetables. No curd!", diet: .vegan),
            Food("koki", "Koki", "🫓", [.carbs, .fiber, .iron],
                 "Thick, crispy flatbread with onion and pomegranate seeds.", diet: .vegan, allergens: [.gluten]),
            Food("tidali-dal", "Tidali Dal", "🍛", [.protein, .iron, .fiber],
                 "Three dals cooked together.", diet: .vegan),
            Food("aloo-tuk", "Aloo Tuk", "🥔", [.carbs, .potassium],
                 "Double-fried smashed potatoes with masala. A sometimes side.", diet: .vegan, sometimes: true),
        ]
    )

    static let maharashtrian = FoodPackage(
        id: "maharashtrian", name: "Marathi Swayampakghar", emoji: "🛺", region: .india,
        summary: "Poha, varan-bhaat, bhakri-pithla, usal and Konkan solkadhi.",
        foods: [
            Food("kanda-poha", "Kanda Poha", "🍛", [.carbs, .iron, .vitaminC],
                 "Flattened rice with onion, turmeric, lemon and peanuts.", diet: .vegan, allergens: [.peanuts]),
            Food("varan-bhaat", "Varan Bhaat with Toop", "🍚", [.protein, .carbs, .healthyFats],
                 "Plain toor dal and rice with a spoon of ghee. Pure comfort.", allergens: [.dairy]),
            Food("thalipeeth", "Thalipeeth", "🥞", [.carbs, .protein, .fiber, .iron],
                 "Multigrain flatbread of bhajani flour, with a dollop of white butter.", allergens: [.gluten, .dairy]),
            Food("bhakri-pithla", "Jowar Bhakri & Pithla", "🫓", [.carbs, .fiber, .protein, .magnesium, .iron],
                 "Sorghum flatbread with thick besan curry. Farmer's lunch!", diet: .vegan),
            Food("misal-usal", "Matki Usal", "🌱", [.protein, .fiber, .iron, .vitaminC],
                 "Sprouted moth beans cooked with goda masala.", diet: .vegan),
            Food("solkadhi", "Solkadhi", "🩷", [.healthyFats, .water, .vitaminC],
                 "Pink kokum and coconut milk drink from the Konkan coast.", diet: .vegan),
            Food("sabudana-khichdi", "Sabudana Khichdi", "⚪️", [.carbs, .potassium],
                 "Tapioca pearls with peanuts and potato. Mostly quick energy.", diet: .vegan, allergens: [.peanuts]),
            Food("ukadiche-modak", "Ukadiche Modak", "🥟", [.carbs],
                 "Ganpati's favourite steamed sweet dumplings.", allergens: [.dairy], sometimes: true),
        ]
    )

    static let tamil = FoodPackage(
        id: "tamil", name: "Tamil Samayalarai", emoji: "🌺", region: .india,
        summary: "Idli, sambar, rasam, keerai and curd rice from Tamil homes.",
        foods: [
            Food("idli-sambar", "Idli Sambar", "⚪️", [.carbs, .protein, .probiotics, .fiber, .bVitamins],
                 "Steamed fermented rice-urad cakes with veggie-filled sambar.", diet: .vegan),
            Food("dosa-chutney", "Dosa & Coconut Chutney", "🫓", [.carbs, .protein, .healthyFats],
                 "Crispy fermented crepe with fresh coconut chutney.", diet: .vegan),
            Food("ven-pongal", "Ven Pongal", "🍚", [.carbs, .protein, .magnesium],
                 "Rice and moong dal with pepper, cumin and ghee.", allergens: [.dairy, .treeNuts]),
            Food("rasam-rice", "Rasam Rice", "🍲", [.vitaminC, .water, .potassium, .carbs],
                 "Peppery tomato-tamarind soup over rice.", diet: .vegan),
            Food("keerai", "Keerai Masiyal", "🥬", [.iron, .calcium, .vitaminA, .magnesium],
                 "Mashed greens with a little dal and garlic.", diet: .vegan),
            Food("curd-rice", "Thayir Sadam", "🍶", [.probiotics, .calcium, .carbs, .water],
                 "Cool curd rice with pomegranate and a mustard tadka.", allergens: [.dairy]),
            Food("sundal", "Chana Sundal", "🫘", [.protein, .fiber, .iron, .healthyFats],
                 "Boiled chickpeas tossed with coconut and curry leaves.", diet: .vegan),
            Food("ragi-koozh", "Ragi Koozh", "🥣", [.calcium, .iron, .carbs, .magnesium, .probiotics],
                 "Fermented finger-millet drink. Calcium champion!", diet: .vegan),
            Food("payasam", "Payasam", "🍮", [.carbs],
                 "Sweet milk pudding for festivals.", allergens: [.dairy, .treeNuts], sometimes: true),
        ]
    )

    static let kerala = FoodPackage(
        id: "kerala", name: "Kerala Adukkala", emoji: "🥥", region: .india,
        summary: "Coconut, curry leaves and rice: puttu, avial, appam and kanji.",
        foods: [
            Food("puttu-kadala", "Puttu & Kadala Curry", "🧆", [.carbs, .protein, .fiber, .iron],
                 "Steamed rice-coconut cylinders with black chickpea curry.", diet: .vegan),
            Food("avial", "Avial", "🥘", [.fiber, .vitaminA, .healthyFats, .potassium],
                 "Mixed vegetables in coconut and curd with coconut oil.", allergens: [.dairy]),
            Food("appam-stew", "Appam & Veg Stew", "🥞", [.carbs, .healthyFats, .vitaminA],
                 "Lacy rice pancakes with a mild coconut-milk stew.", diet: .vegan),
            Food("thoran", "Cabbage Thoran", "🥬", [.fiber, .vitaminC, .healthyFats],
                 "Stir-fried cabbage with grated coconut.", diet: .vegan),
            Food("meen-curry", "Meen Curry", "🐟", [.protein, .omega3, .vitaminD],
                 "Tangy fish curry with kudampuli.", diet: .nonVegetarian, allergens: [.fish]),
            Food("kanji-payar", "Kanji & Cherupayar", "🥣", [.water, .carbs, .protein, .fiber],
                 "Rice gruel with green gram. What grandma makes on sick days.", diet: .vegan),
            Food("egg-roast", "Mutta Roast", "🥚", [.protein, .vitaminD, .bVitamins],
                 "Boiled eggs in a thick onion masala.", diet: .eggetarian, allergens: [.egg]),
            Food("banana-chips", "Banana Chips", "🍌", [.carbs],
                 "Fried in coconut oil and salted. Sometimes crunch!", diet: .vegan, sometimes: true),
        ]
    )

    static let andhra = FoodPackage(
        id: "andhra", name: "Telugu Vantillu", emoji: "🌶️", region: .india,
        summary: "Pesarattu, pappu and ragi sangati from Andhra and Telangana.",
        foods: [
            Food("pesarattu", "Pesarattu", "🥞", [.protein, .iron, .fiber, .bVitamins],
                 "Green moong dosa with ginger.", diet: .vegan),
            Food("gongura-pappu", "Gongura Pappu", "🍛", [.protein, .iron, .vitaminC],
                 "Toor dal with tangy sorrel leaves.", diet: .vegan),
            Food("ragi-sangati", "Ragi Sangati", "🟤", [.calcium, .iron, .carbs, .magnesium],
                 "Finger-millet and rice balls, eaten with curry.", diet: .vegan),
            Food("majjiga", "Majjiga", "🥛", [.probiotics, .water, .calcium],
                 "Spiced buttermilk with curry leaves and ginger.", allergens: [.dairy]),
            Food("tomato-pappu", "Tomato Pappu", "🍅", [.protein, .vitaminC, .potassium],
                 "Toor dal cooked with lots of tomatoes.", diet: .vegan),
        ]
    )

    static let kannada = FoodPackage(
        id: "kannada", name: "Kannada Adige", emoji: "🐘", region: .india,
        summary: "Ragi mudde, bisi bele bath, akki rotti and kosambari.",
        foods: [
            Food("ragi-mudde", "Ragi Mudde & Saaru", "🟤", [.calcium, .iron, .carbs, .magnesium, .fiber],
                 "Finger-millet balls dipped in thin dal saaru. Farmers' strength food.", diet: .vegan),
            Food("bisi-bele-bath", "Bisi Bele Bath", "🍲", [.protein, .carbs, .fiber, .vitaminA],
                 "Rice, dal and vegetables cooked into one hot, tangy pot.", diet: .vegan),
            Food("akki-rotti", "Akki Rotti", "🫓", [.carbs, .fiber, .vitaminA],
                 "Rice-flour flatbread with carrot, dill and coconut.", diet: .vegan),
            Food("kosambari", "Kosambari", "🥗", [.protein, .vitaminC, .water, .fiber],
                 "Soaked moong dal salad with cucumber, carrot and lemon.", diet: .vegan),
            Food("neer-dosa", "Neer Dosa", "🫓", [.carbs],
                 "Soft, lacy rice crepes from Mangaluru. Plain, gentle fuel.", diet: .vegan),
            Food("mysore-pak", "Mysore Pak", "🟨", [.carbs],
                 "Rich besan-ghee-sugar sweet. A sometimes treat!", allergens: [.dairy], sometimes: true),
        ]
    )
}

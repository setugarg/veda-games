# veda-games

Veda Games. Includes `index.html` (web learning games) and **Tiffin Tales**, a native iOS game.

## 🍱 Tiffin Tales (iOS, SwiftUI)

A gentle story game for 5–10 year olds that passes on the food wisdom held by parents and grandparents: what to eat with what, what to eat in which season, kitchen tricks like soaking, sprouting and fermenting, and the home remedies families trust. Each tradition is paired with what modern science says about it.

The child's character (default name **Veda**, editable) and **Tiffy**, a talking steel tiffin box from Dadi's kitchen, live through one year of small adventures. Each mission is a tricky spot: a sleepy Monday, a spelling bee, a relay race, a scratchy throat, a peanut-allergic friend. The way out is to eat well or use the right home remedy.

### How a mission plays

1. **Tricky spot.** The character looks sleepy, worried, tired or sick, and the situation is read aloud.
2. **Open the tiffin.** The child sees what's needed (🧠 Focus, ⚡ Energy, 💪 Strength, 🤸 Bendy Muscles…) and a 3×3 grid of dishes from the family's pantry. Each card shows the superpowers it gives. A couple of "sometimes foods" (chips, jalebi, cola) are mixed in to tempt them.
3. **Fill the plate (up to 3) → Eat!** Food floats into the character, and each covered need lights up one by one.
4. **Out of the tricky spot.** The character celebrates and the story moves on. A "What helped?" card explains *why*: "Rajma Chawal gave 🧠 Focus ← Iron, B Vitamins".
5. If something is still missing, Tiffy gives a hint: "Foods with Iron or Omega-3 give Focus. Look for 🧠 on the cards!"

**Grandma Wisdom missions:** Dadi (or Nani, Ba, Aaji, whatever the child calls their grandparent) asks a kitchen question: *"Palak dal has shy iron. What do we squeeze on top?"* 🍋. The version depends on the family's cultures. A Mexican family gets *frijoles + corn tortillas* where an Indian family gets *dal-chawal*; a Bihari family's summer cooler is *sattu*, an Odia family's is *pakhala*. Each answer opens a card with **👵🏽 Dadi says** (the tradition), **🔬 Science says** (what researchers found) and an honest evidence badge: *Science agrees* / *partly agrees* / *Family tradition, scientists are still studying it*.

**Grandma Combos:** when the child's plate in a meal mission holds a classic pairing (dal + grain = complete protein, iron + vitamin C, vitamin A + a little fat, calcium + vitamin D, good bacteria + fiber), a ✨ Grandma Combo pops up explaining why families eat them together.

**Ask Your Elders missions:** the game sends the child to a real grandparent with a question ("What did you eat when you had a cold as a child?") and records the answer in their voice. It's saved to the Wisdom Book.

**Remedy missions** work the same way, with home-remedy cards instead of dishes. The child also learns what's happening in the body, how the remedy helps, how to make it *with a grown-up*, and when to see a doctor.

### What's inside (v0.1)

| | |
|---|---|
| **Indian home kitchens (16)** | Baniya, Jain, Rajasthani, Gujarati, Odia, Bengali, Bihari, Assamese, Punjabi, Kashmiri, Sindhi, Marathi, Tamil, Kerala, Telugu, Kannada |
| **World kitchens (9)** | Japanese, Chinese, Korean, Mexican, Middle Eastern, Italian, West African, Ethiopian, American/British |
| **Remedy packs (9)** | Everyday Care (always on), Dadi-Nani ke Nuskhe, West Indian (Gujarati/Marwari/Marathi), East Indian (Odia/Bengali/Bihari), Paati Vaidhyam (South India), East Asian, Latin American, Mediterranean & Middle Eastern, American & European |
| **Content** | 205 dishes · 62 remedies · 16 nutrients (5 macros, 10 micros, good bacteria) · 13 mild ailments |
| **Grandma wisdom (45 cards, 14 topics)** | Pairings (dal-chawal, idli-sambar, saag-makki, beans + corn, haldi + black pepper, lemon on dal, hing in rajma, epazote in frijoles), kitchen magic (soaking, sprouting, fermenting idli, dhokla, pakhala, kimchi, injera), seasons (chaas, sattu, pakhala, kokum, neer mor, agua fresca, barley tea; bajra-gur, til-gul, winter greens), after meals (saunf, mukhwas, curd rice, mint tea), balanced plates (thali, Bengali bitter-first, ichiju-sansai, three sisters), habits (breakfast, shatapavali walk) |
| **Story** | 8 chapters, 53 bite-sized missions: School, Sports Day, Nani's Village, Monsoon, Science Fair, Friends & Allergies, Winter Camp, Grandparents' Day |

### The education model

Superpowers are **derived from nutrients**, never hand-assigned, so the game can always explain itself:

- Carbs → ⚡ Energy · Protein → 💪 Strength, 🏃 Stamina · Fiber → 🌀 Happy Tummy, 🏃 Stamina
- Iron → 🧠 Focus, 🏃 Stamina · Omega-3 → 🧠 Focus, 😌 Calm · Magnesium → 🤸 Bendy Muscles, 😌 Calm
- Calcium / Vitamin D → 🦴 Strong Bones · Vitamins A, C, Zinc, Good Bacteria → 🛡️ Germ Shield · …

The **Wisdom Book** is the heart of the game. It holds the family's own tips and recordings, "Ask Your Elders" interview questions, Grandma Combos found on plates, and every wisdom card learned. The **Nutrient Book** fills up as the child eats foods containing each nutrient. The **Remedy Book** collects learned remedies. **My Pantry** lets kids browse their family's dishes and tap any one to see what's inside.

### For grown-ups

Tap ⚙️ and solve the multiplication gate to:

- pick **food packages** (cultures) and **remedy packages**
- set **diet** (vegan / vegetarian / + eggs / everything) and **allergies**. Dishes that don't fit never appear.
- set the child's **name**, what they call their **grandparent**, and design their **character** (skin tone, hair, outfit)
- add **Our Family's Wisdom**: your own pairings, seasonal habits and remedies, typed or recorded in a grandparent's voice. They appear in the Wisdom Book and as a daily tip on the home screen
- turn read-aloud on or off, or reset progress

Every mission stays solvable: the Everyday Pantry and Everyday Care packs are always included, and the mission engine guarantees the grid contains a winning plate. `Tools/ContentCheck.swift` verifies this across strict, default and "everything" settings.

> Remedies are traditional home care for mild, everyday troubles, not medical advice. Every remedy shows "make it with a grown-up" steps, safety cautions, and when to see a doctor.

### Design

- Pure SwiftUI, iOS 17+, iPhone and iPad. No image assets, no third-party dependencies.
- The character and Tiffy are drawn with shapes, so moods (sleepy, worried, sick, tired, happy, excited) animate smoothly: blinking, breathing, a mouth that morphs between frown and smile, mood badges.
- Soft pastel palette, rounded type, spring animations, gentle haptics, pastel confetti.
- Read-aloud narration (`AVSpeechSynthesizer`, Indian-English voice when available) for early readers.
- Progress and settings are saved locally (`UserDefaults`); voice recordings are local `.m4a` files. No accounts, no network, no ads.

### Run it

Requires **Xcode 16+**.

```bash
open TiffinTales.xcodeproj   # pick an iPhone simulator and press ⌘R
```

Alternatively, regenerate the project with [XcodeGen](https://github.com/yonaskolb/XcodeGen): `xcodegen` (uses `project.yml`).

Check content (any machine with a Swift toolchain, including Linux):

```bash
swiftc -parse-as-library TiffinTales/Models/*.swift TiffinTales/Content/*.swift \
  TiffinTales/Engine/*.swift Tools/ContentCheck.swift -o /tmp/content-check && /tmp/content-check
```

### Project layout

```
TiffinTales/
  App/        app entry and navigation router
  Models/     Nutrient, Benefit, Allergen, Diet, Food, Remedy, Ailment, Mission, Chapter
  Content/    Everyday, India and World food packs, remedy packs, the story
  Engine/     Catalog (pantry from settings), MissionEngine (options, scoring), GameStore (persistence)
  Views/      Theme, components (character, Tiffy, cards, confetti), screens
Tools/        ContentCheck.swift (content validation), make_icon.py (app icon)
```

To add a culture, add a `FoodPackage` to `Content/IndiaPackages.swift` or `Content/WorldPackages.swift` and include it in `all`. Nutrients drive everything else.

### Ideas for next iterations

- Hand-illustrated dish art in place of emoji, plus ambient sound and music
- Regional language names and narration (Hindi, Gujarati, Odia, Tamil…)
- Turn family tips into playable missions ("Nani's quiz") and share a family's wisdom pack with cousins
- More combos and "don't mix" traditions, each with its honest evidence badge
- Jain / no-onion-garlic and fasting-day filters; seasonal menus (winter vs summer foods)
- Meal-time slots (breakfast, tiffin, dinner) and a "build a balanced thali" mode
- Parent dashboard: what the child learned, and a "cook it together" recipe card
- More chapters (festivals, travel, a new sibling) and replayable daily mini-missions

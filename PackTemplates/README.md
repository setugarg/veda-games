# Pack templates

Food and remedies live in JSON files in `TiffinTales/Resources/Packs/`. The app loads every
`kitchen-*.json` and `remedies-*.json` it finds, so **adding a culture needs no code**:

1. Copy `kitchen.template.json` (or `remedies.template.json`) to
   `TiffinTales/Resources/Packs/kitchen-<id>.json` (or `remedies-<id>.json`).
2. Fill it in. Only `id`, `name`, `emoji` and `nutrients` (or `treats`) are required on each item.
3. Tidy the formatting: `python3 Tools/format_packs.py TiffinTales/Resources/Packs/*.json`
4. Validate: build and run `Tools/ContentCheck.swift` (see the main README). It checks ids are unique,
   values are valid, and every mission stays winnable.

Files starting with `_` are ignored, so drafts can sit next to real packs.

Parents can also create dishes and remedies inside the app (Grown-ups → Made by our family).
Those use the same format and are saved on the device.

## Kitchen pack fields

| Field | Required | Notes |
|---|---|---|
| `id` | ✓ | Unique, lowercase-with-dashes. Matches the file name. |
| `name`, `emoji` | ✓ | Shown to parents and kids. |
| `region` | ✓ | One of the regions below. Groups packs in the settings screen. |
| `countries` | | ISO 3166 country codes. Packs are suggested to families whose device region matches. |
| `elderNames` | | What kids in this culture call their grandparents. The first one becomes the default. |
| `summary` | | One sentence for parents. |
| `featured` | | `true` to suggest this pack first for its countries (useful when a country has many packs). |
| `foods` | ✓ | List of dishes. |

## Dish fields

| Field | Required | Notes |
|---|---|---|
| `id` | ✓ | Unique across **all** packs. |
| `name`, `emoji` | ✓ | |
| `localName` | | The home name, e.g. "Frijoles de olla". |
| `blurb` | | One or two kid-friendly sentences. |
| `nutrients` | ✓ | What it's a *good source* of, strongest first. Superpowers are derived from these. |
| `tags` | | Kinds of dish. `legume` + `grain` on a plate makes the "complete protein" Grandma Combo. |
| `diet` | | Default `vegetarian`. A family only sees dishes at or below its diet. |
| `allergens` | | Dishes containing a family's allergens are never shown. |
| `sometimes` | | `true` for festival/party treats. They tempt kids but give no superpowers. |

## Remedy fields

| Field | Required | Notes |
|---|---|---|
| `id`, `name`, `emoji` | ✓ | |
| `treats` | ✓ | Which ailments it soothes. |
| `howItHelps` | | The key ingredient and why, for kids. |
| `steps` | | Each step is shown as "make it with a grown-up". |
| `caution` | | Safety note (hot water, not for babies, don't swallow…). |
| `diet`, `allergens` | | Same as dishes. |

Remedies must be gentle home care for mild, everyday troubles. The game always shows when to see a doctor.

## Allowed values

- **region:** `southAsia`, `eastAsia`, `southeastAsia`, `middleEast`, `africa`, `europe`, `latinAmerica`, `northAmerica`, `oceania`
- **nutrients:** `carbs`, `protein`, `healthyFats`, `fiber`, `water`, `iron`, `calcium`, `vitaminA`, `vitaminC`, `vitaminD`, `bVitamins`, `potassium`, `magnesium`, `zinc`, `omega3`, `probiotics`
- **tags:** `legume`, `grain`, `greens`, `fermented`
- **diet:** `vegan`, `vegetarian`, `eggetarian`, `nonVegetarian`
- **allergens:** `dairy`, `peanuts`, `treeNuts`, `gluten`, `egg`, `soy`, `fish`, `sesame`
- **treats (ailments):** `soreThroat`, `sniffles`, `cough`, `tummyAche`, `travelTummy`, `stuckTummy`, `toothache`, `mildHeadache`, `sneezyAllergy`, `itchyBite`, `tooHot`, `tiredMuscles`, `hiccups`

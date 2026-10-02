import SwiftUI

/// What's inside a dish: macros, micros and the superpowers they give.
struct FoodDetailView: View {
    let food: Food
    @Environment(\.dismiss) private var dismiss

    private var readAloud: String {
        var text = "\(food.name). \(food.blurb) "
        if food.isSometimes {
            text += "This is a sometimes food."
        } else {
            text += "It has " + food.nutrients.map(\.name).joined(separator: ", ") + "."
        }
        return text
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top) {
                    Text(food.emoji).font(.system(size: 64))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(food.name).font(.kid(24, weight: .heavy)).foregroundStyle(Palette.ink)
                        if let local = food.localName {
                            Text(local).font(.kid(16, weight: .semibold)).foregroundStyle(Palette.inkSoft)
                        }
                        if let pack = Catalog.package(of: food) {
                            Text("\(pack.emoji) \(pack.name)").font(.kid(13, weight: .bold)).foregroundStyle(Palette.inkSoft)
                        }
                    }
                    Spacer()
                    SpeakButton(text: readAloud)
                }

                Text(food.blurb).font(.kid(17, weight: .semibold)).foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                if food.isSometimes {
                    Text("🎉 This is a sometimes food. Lots of sugar, oil or salt and not many helpers. Enjoy it at parties and festivals, and pick everyday foods for tricky spots!")
                        .font(.kid(15, weight: .semibold))
                        .foregroundStyle(Palette.ink)
                        .padding(14)
                        .puffyCard(Palette.butter)
                } else {
                    section("Big nutrients (macros)", nutrients: food.macros, color: Palette.peach)
                    section("Tiny helpers (micros)", nutrients: food.micros, color: Palette.sky)

                    Text("Superpowers").font(.kid(17, weight: .heavy)).foregroundStyle(Palette.ink)
                    ForEach(Benefit.allCases.filter(food.benefits.contains)) { benefit in
                        HStack {
                            Text(benefit.emoji).font(.system(size: 22))
                            Text(benefit.name).font(.kid(15, weight: .heavy))
                            Text("from " + food.nutrients(giving: benefit).map(\.name).joined(separator: " & "))
                                .font(.kid(14, weight: .semibold))
                                .foregroundStyle(Palette.inkSoft)
                        }
                        .foregroundStyle(Palette.ink)
                    }
                }

                if !food.allergens.isEmpty {
                    Text("Contains: " + food.allergens.sorted { $0.rawValue < $1.rawValue }.map { "\($0.emoji) \($0.name)" }.joined(separator: ", "))
                        .font(.kid(14, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .padding(12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .puffyCard(Palette.rose)
                }
            }
            .padding(20)
        }
        .background(Palette.cream.ignoresSafeArea())
    }

    @ViewBuilder
    private func section(_ title: String, nutrients: [Nutrient], color: Color) -> some View {
        if !nutrients.isEmpty {
            Text(title).font(.kid(17, weight: .heavy)).foregroundStyle(Palette.ink)
            FlowLayout(spacing: 8) {
                ForEach(nutrients) { NutrientChip(nutrient: $0) }
            }
        }
    }
}

/// A collectible encyclopaedia of nutrients. Locked ones show as mystery cards
/// until the child eats a food containing them in a mission.
struct NutrientBookView: View {
    @Environment(GameStore.self) private var store
    @State private var selected: Nutrient?

    var body: some View {
        ZStack {
            PastelBackground(tint: 3)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TiffySays(text: "Every food has helpers inside. Eat them in missions to collect them all!", size: 50)
                    group("Big nutrients (macros)", Nutrient.allCases.filter(\.isMacro))
                    group("Tiny helpers (micros)", Nutrient.allCases.filter { !$0.isMacro })
                }
                .padding(16)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Nutrient Book")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { nutrient in
            NutrientDetailView(nutrient: nutrient).presentationDetents([.medium, .large])
        }
    }

    private func group(_ title: String, _ nutrients: [Nutrient]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.kid(20, weight: .heavy)).foregroundStyle(Palette.ink)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: 12)], spacing: 12) {
                ForEach(nutrients) { nutrient in
                    let found = store.progress.discoveredNutrients.contains(nutrient)
                    Button {
                        Haptics.tap()
                        selected = nutrient
                    } label: {
                        VStack(spacing: 6) {
                            Text(found ? nutrient.emoji : "❔").font(.system(size: 38))
                            Text(nutrient.name).font(.kid(15, weight: .heavy)).foregroundStyle(Palette.ink)
                            Text(found ? nutrient.nickname : "Not found yet")
                                .font(.kid(12, weight: .semibold))
                                .foregroundStyle(Palette.inkSoft)
                                .multilineTextAlignment(.center)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 130)
                        .puffyCard(found ? (nutrient.isMacro ? Palette.peach : Palette.sky) : Color.white.opacity(0.7))
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }
}

struct NutrientDetailView: View {
    let nutrient: Nutrient
    @Environment(GameStore.self) private var store

    var body: some View {
        let foods = store.pantry.foods.filter { $0.nutrients.contains(nutrient) }
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(nutrient.emoji).font(.system(size: 56))
                    VStack(alignment: .leading) {
                        Text(nutrient.name).font(.kid(26, weight: .heavy))
                        Text(nutrient.nickname).font(.kid(16, weight: .semibold)).foregroundStyle(Palette.inkSoft)
                    }
                    Spacer()
                    SpeakButton(text: "\(nutrient.name), \(nutrient.nickname). \(nutrient.explanation)")
                }
                .foregroundStyle(Palette.ink)

                Text(nutrient.isMacro ? "A big nutrient (macro): your body needs lots of it." : "A tiny helper (micro): you need only a little, but it's super important.")
                    .font(.kid(14, weight: .bold))
                    .foregroundStyle(Palette.inkSoft)

                Text(nutrient.explanation).font(.kid(17, weight: .semibold)).foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Superpowers").font(.kid(17, weight: .heavy)).foregroundStyle(Palette.ink)
                FlowLayout(spacing: 8) {
                    ForEach(nutrient.benefits) { NeedChip(benefit: $0, filled: true) }
                }

                if !foods.isEmpty {
                    Text("Find it in your pantry").font(.kid(17, weight: .heavy)).foregroundStyle(Palette.ink)
                    FlowLayout(spacing: 8) {
                        ForEach(foods.prefix(18)) { food in
                            Text("\(food.emoji) \(food.name)")
                                .font(.kid(13, weight: .semibold))
                                .foregroundStyle(Palette.ink)
                                .padding(.horizontal, 10).padding(.vertical, 6)
                                .background(Capsule().fill(Palette.soft(Palette.tint(for: food.id))))
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(Palette.cream.ignoresSafeArea())
    }
}

/// All the remedies in the family's packages; learned ones are highlighted.
struct RemedyBookView: View {
    @Environment(GameStore.self) private var store
    @State private var selected: Remedy?

    var body: some View {
        let remedies = store.pantry.remedies
        ZStack {
            PastelBackground(tint: 6)
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    TiffySays(text: "Grandmas everywhere have clever tricks for feeling better. Always make them with a grown-up!", size: 50)
                    ForEach(Ailment.allCases) { ailment in
                        let helpers = remedies.filter { $0.treats.contains(ailment) }
                        if !helpers.isEmpty {
                            Text("\(ailment.emoji) \(ailment.name)")
                                .font(.kid(18, weight: .heavy))
                                .foregroundStyle(Palette.ink)
                                .padding(.top, 6)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(helpers) { remedy in
                                        let learned = store.progress.learnedRemedies.contains(remedy.id)
                                        Button { selected = remedy } label: {
                                            VStack(spacing: 4) {
                                                Text(remedy.emoji).font(.system(size: 30))
                                                Text(remedy.name)
                                                    .font(.kid(13, weight: .heavy))
                                                    .foregroundStyle(Palette.ink)
                                                    .multilineTextAlignment(.center)
                                                    .lineLimit(3)
                                                if learned {
                                                    Image(systemName: "checkmark.seal.fill").foregroundStyle(Palette.mintDeep)
                                                }
                                            }
                                            .padding(10)
                                            .frame(width: 130, height: 130)
                                            .puffyCard(learned ? Palette.mint : Color.white, radius: 20)
                                        }
                                        .buttonStyle(PressableStyle())
                                    }
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Remedy Book")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { remedy in
            ScrollView {
                RemedyLessonCard(remedy: remedy, ailment: remedy.treats.sorted { $0.rawValue < $1.rawValue }.first)
                    .padding(16)
            }
            .background(Palette.cream.ignoresSafeArea())
            .presentationDetents([.medium, .large])
        }
    }
}

/// Browse every dish the family has stocked, by kitchen.
struct PantryView: View {
    @Environment(GameStore.self) private var store
    @State private var selected: Food?

    var body: some View {
        let pantry = store.pantry
        let allowed = Set(pantry.foods.map(\.id) + pantry.treats.map(\.id))
        let packages = Catalog.foodPackages.filter { $0.isCore || store.settings.foodPackages.contains($0.id) }
        ZStack {
            PastelBackground(tint: 0)
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    TiffySays(text: "These are the foods your family picked. Tap one to see what's inside!", size: 50)
                    ForEach(packages) { package in
                        let foods = package.foods.filter { allowed.contains($0.id) }
                        if !foods.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(package.emoji) \(package.name)")
                                    .font(.kid(19, weight: .heavy))
                                    .foregroundStyle(Palette.ink)
                                Text(package.summary)
                                    .font(.kid(13, weight: .semibold))
                                    .foregroundStyle(Palette.inkSoft)
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 10)], spacing: 10) {
                                    ForEach(foods) { food in
                                        FoodCard(food: food) { selected = food }
                                            .onTapGesture { selected = food }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("My Pantry")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { food in
            FoodDetailView(food: food).presentationDetents([.medium, .large])
        }
    }
}

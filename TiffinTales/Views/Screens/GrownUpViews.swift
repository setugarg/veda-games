import SwiftUI

/// A simple parental gate: a multiplication question young kids can't easily answer.
struct GrownUpGate: View {
    var onPass: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var a = Int.random(in: 6...9)
    @State private var b = Int.random(in: 6...9)
    @State private var choices: [Int] = []
    @State private var shake: CGFloat = 0

    var body: some View {
        VStack(spacing: 22) {
            Text("For grown-ups")
                .font(.kid(26, weight: .heavy))
            Text("To open the pantry settings, please answer:")
                .font(.kid(16, weight: .semibold))
                .foregroundStyle(Palette.inkSoft)
                .multilineTextAlignment(.center)
            Text("\(a) × \(b) = ?")
                .font(.kid(40, weight: .heavy))
                .modifier(Shake(animatableData: shake))
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
                ForEach(choices, id: \.self) { value in
                    Button("\(value)") {
                        if value == a * b {
                            onPass()
                        } else {
                            Haptics.oops()
                            withAnimation(.linear(duration: 0.4)) { shake += 1 }
                            reroll()
                        }
                    }
                    .buttonStyle(SquishyButtonStyle(color: Palette.lavenderDeep))
                }
            }
            Button("Cancel") { dismiss() }
                .font(.kid(16))
                .foregroundStyle(Palette.inkSoft)
        }
        .foregroundStyle(Palette.ink)
        .padding(28)
        .frame(maxWidth: 420)
        .presentationDetents([.medium])
        .onAppear(perform: reroll)
    }

    private func reroll() {
        a = Int.random(in: 6...9)
        b = Int.random(in: 6...9)
        let answer = a * b
        var set: Set<Int> = [answer]
        while set.count < 4 { set.insert(answer + [-10, -6, -3, 2, 4, 7, 9].randomElement()!) }
        choices = set.shuffled()
    }
}

/// Where parents curate the pantry: cultures, remedies, diet, allergies and the child's character.
struct ParentSettingsView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var confirmReset = false
    @State private var expandedRegions: Set<WorldRegion> = []

    var body: some View {
        @Bindable var store = store
        NavigationStack {
            Form {
                Section {
                    TextField("Child's name", text: $store.settings.childName)
                        .font(.kid(17, weight: .semibold))
                    TextField("What they call their grandparent", text: $store.settings.elderName)
                        .font(.kid(17, weight: .semibold))
                    FlowLayout(spacing: 6) {
                        ForEach(Catalog.elderNameSuggestions(for: store.settings), id: \.self) { name in
                            Text(name)
                                .font(.kid(13, weight: .bold))
                                .foregroundStyle(Palette.ink)
                                .padding(.horizontal, 10).padding(.vertical, 5)
                                .background(Capsule().fill(store.settings.elderName == name ? Palette.mint : Palette.lavender.opacity(0.5)))
                                .onTapGesture { store.settings.elderName = name }
                        }
                    }
                    AvatarPicker(avatar: $store.settings.avatar)
                    Toggle("Read stories aloud", isOn: $store.settings.readAloud)
                } header: {
                    Text("Your child")
                } footer: {
                    Text("The story uses these names. The grandparent teaches family food wisdom in the game.")
                }

                Section {
                    Picker("Our family eats", selection: $store.settings.diet) {
                        ForEach(Diet.allCases) { Text($0.name).tag($0) }
                    }
                    ForEach(Allergen.allCases) { allergen in
                        Toggle(isOn: Binding(
                            get: { store.settings.allergies.contains(allergen) },
                            set: { on in
                                if on { store.settings.allergies.insert(allergen) } else { store.settings.allergies.remove(allergen) }
                            })) {
                            Text("\(allergen.emoji)  \(allergen.name)")
                        }
                    }
                } header: {
                    Text("Diet & allergies")
                } footer: {
                    Text("Dishes that don't fit are never shown. Allergy-safety missions still teach your child to check for allergens.")
                }

                Section {
                    NavigationLink {
                        FamilyKitchenEditor()
                    } label: {
                        Label("Our Family Kitchen (\(store.familyFoods.count) dishes)", systemImage: "frying.pan.fill")
                            .font(.kid(16, weight: .heavy))
                    }
                    NavigationLink {
                        FamilyRemediesEditor()
                    } label: {
                        Label("Our Family Remedies (\(store.familyRemedies.count))", systemImage: "cross.vial.fill")
                            .font(.kid(16, weight: .heavy))
                    }
                    NavigationLink {
                        FamilyWisdomEditor()
                    } label: {
                        Label("Our Family's Wisdom (\(store.familyTips.count))", systemImage: "heart.text.square.fill")
                            .font(.kid(16, weight: .heavy))
                    }
                } header: {
                    Text("Made by our family")
                } footer: {
                    Text("Add the dishes you actually cook, the remedies your family trusts, and the food wisdom your parents taught you. They show up in your child's missions, pantry and books.")
                }

                Section {
                    ForEach(foodRegions) { region in
                        DisclosureGroup(isExpanded: expansion(region)) {
                            ForEach(Catalog.foodPackages.filter { $0.region == region }) { pack in
                                let dishes = pack.foods.filter { $0.isAllowed(for: store.settings.diet, avoiding: store.settings.allergies) }.count
                                packageRow(emoji: pack.emoji, name: pack.name, summary: pack.summary,
                                           count: "\(dishes) dishes for you", isOn: membership(pack.id, in: \.foodPackages), locked: false)
                            }
                        } label: {
                            regionLabel(region, selected: Catalog.foodPackages.filter { $0.region == region && store.settings.foodPackages.contains($0.id) }.count)
                        }
                    }
                    Button("Use suggestions for my country") {
                        let suggestion = Catalog.suggestedPacks(forCountry: Locale.current.region?.identifier)
                        store.settings.foodPackages = suggestion.food
                        store.settings.remedyPackages = suggestion.remedies
                    }
                    .font(.kid(15, weight: .bold))
                } header: {
                    Text("Kitchens of the world")
                } footer: {
                    Text("Pick the cuisines your family cooks, or ones you'd love your child to discover. The Everyday Pantry (fruit, milk, eggs, seeds, water…) is always included.")
                }

                Section {
                    ForEach(Catalog.remedyPackages.filter { $0.id != ContentLibrary.familyRemediesID }) { pack in
                        if pack.isCore {
                            packageRow(emoji: pack.emoji, name: pack.name, summary: pack.summary,
                                       count: "\(pack.remedies.count) remedies", isOn: .constant(true), locked: true)
                        } else {
                            packageRow(emoji: pack.emoji, name: pack.name, summary: pack.summary,
                                       count: "\(pack.region.emoji) \(pack.region.name) · \(pack.remedies.count) remedies",
                                       isOn: membership(pack.id, in: \.remedyPackages), locked: false)
                        }
                    }
                } header: {
                    Text("Home remedy packs")
                } footer: {
                    Text("Remedies are traditional home care for mild, everyday troubles. They are not medical advice. Every remedy in the game reminds children to ask a grown-up and to see a doctor if they don't feel better. Honey is never suitable for babies under one.")
                }

                Section {
                    Button("Reset story progress", role: .destructive) { confirmReset = true }
                }
            }
            .navigationTitle("Pantry & Settings")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if expandedRegions.isEmpty {
                    expandedRegions = Set(foodRegions.filter { region in
                        Catalog.foodPackages.contains { $0.region == region && store.settings.foodPackages.contains($0.id) }
                    })
                }
            }
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }.font(.kid(17))
                }
            }
            .confirmationDialog("Reset all stars and collected nutrients?", isPresented: $confirmReset, titleVisibility: .visible) {
                Button("Reset", role: .destructive) { store.resetProgress() }
            }
        }
        .onChange(of: store.settings) { store.saveSettings() }
    }

    private var foodRegions: [WorldRegion] {
        WorldRegion.allCases.filter { region in
            region != .everyday && region != .family && Catalog.foodPackages.contains { $0.region == region }
        }
    }

    private func expansion(_ region: WorldRegion) -> Binding<Bool> {
        Binding(get: { expandedRegions.contains(region) },
                set: { open in
                    if open { expandedRegions.insert(region) } else { expandedRegions.remove(region) }
                })
    }

    private func regionLabel(_ region: WorldRegion, selected: Int) -> some View {
        HStack {
            Text("\(region.emoji)  \(region.name)").font(.kid(16, weight: .heavy))
            Spacer()
            if selected > 0 {
                Text("\(selected) chosen")
                    .font(.kid(12, weight: .bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Palette.mintDeep))
            }
        }
    }

    private func packageRow(emoji: String, name: String, summary: String, count: String, isOn: Binding<Bool>, locked: Bool) -> some View {
        Toggle(isOn: isOn) {
            HStack(alignment: .top, spacing: 12) {
                Text(emoji).font(.system(size: 28))
                VStack(alignment: .leading, spacing: 3) {
                    Text(name).font(.kid(16, weight: .heavy))
                    Text(summary).font(.kid(13, weight: .regular)).foregroundStyle(.secondary)
                    Text(locked ? "Always included" : count).font(.kid(12, weight: .bold)).foregroundStyle(Palette.lavenderDeep)
                }
            }
        }
        .disabled(locked)
    }

    private func membership(_ id: String, in keyPath: WritableKeyPath<FamilySettings, Set<String>>) -> Binding<Bool> {
        Binding(
            get: { store.settings[keyPath: keyPath].contains(id) },
            set: { on in
                if on { store.settings[keyPath: keyPath].insert(id) } else { store.settings[keyPath: keyPath].remove(id) }
            })
    }
}

/// Let the child (with a grown-up) design their character.
struct AvatarPicker: View {
    @Binding var avatar: AvatarStyle

    var body: some View {
        VStack(spacing: 14) {
            CharacterView(mood: .happy, avatar: avatar, size: 110)
                .frame(maxWidth: .infinity)
            row("Skin", count: Palette.skinTones.count, selection: $avatar.skinTone) { Palette.skinTones[$0] }
            row("Hair", count: Palette.hairColors.count, selection: $avatar.hairColor) { Palette.hairColors[$0] }
            row("Outfit", count: Palette.outfits.count, selection: $avatar.outfitColor) { Palette.outfits[$0] }
            HStack {
                Text("Style").font(.kid(14, weight: .bold)).frame(width: 60, alignment: .leading)
                Picker("Hair style", selection: $avatar.hairStyle) {
                    Text("Short").tag(0)
                    Text("Bun").tag(1)
                    Text("Curly").tag(2)
                    Text("Plaits").tag(3)
                }
                .pickerStyle(.segmented)
            }
        }
        .padding(.vertical, 8)
    }

    private func row(_ title: String, count: Int, selection: Binding<Int>, color: @escaping (Int) -> Color) -> some View {
        HStack {
            Text(title).font(.kid(14, weight: .bold)).frame(width: 60, alignment: .leading)
            ForEach(0..<count, id: \.self) { index in
                Circle()
                    .fill(color(index))
                    .frame(width: 34, height: 34)
                    .overlay(Circle().stroke(selection.wrappedValue == index ? Palette.ink : .clear, lineWidth: 3))
                    .onTapGesture {
                        Haptics.tap()
                        withAnimation(.spring) { selection.wrappedValue = index }
                    }
            }
            Spacer()
        }
    }
}

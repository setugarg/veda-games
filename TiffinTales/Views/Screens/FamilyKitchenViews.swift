import SwiftUI

// MARK: - Family Kitchen (custom dishes)

/// Parents list, add and edit the dishes their family actually cooks.
struct FamilyKitchenEditor: View {
    @Environment(GameStore.self) private var store
    @State private var editing: Food?
    @State private var pickingTemplate = false

    var body: some View {
        List {
            Section {
                Button {
                    pickingTemplate = true
                } label: {
                    Label("Add a family dish", systemImage: "plus.circle.fill")
                        .font(.kid(16, weight: .heavy))
                }
            } footer: {
                Text("Add the dishes you cook at home. Start from a template (\"beans + a grain\", \"leafy greens\"…) and we'll fill in the nutrients, or copy a dish from any kitchen in the app and make it your own.")
            }

            if !store.familyFoods.isEmpty {
                Section("Our dishes") {
                    ForEach(store.familyFoods) { food in
                        Button { editing = food } label: {
                            HStack(spacing: 12) {
                                Text(food.emoji).font(.system(size: 30))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(food.name).font(.kid(16, weight: .heavy)).foregroundStyle(Palette.ink)
                                    Text(food.isSometimes ? "Sometimes food" : food.nutrients.map(\.name).joined(separator: ", "))
                                        .font(.kid(12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { store.familyFoods[$0] }.forEach(store.deleteFamilyFood)
                    }
                }
            }
        }
        .navigationTitle("Our Family Kitchen")
        .sheet(isPresented: $pickingTemplate) {
            DishTemplatePicker { food in
                pickingTemplate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { editing = food }
            }
        }
        .sheet(item: $editing) { food in
            FoodEditorView(food: food, isNew: !store.familyFoods.contains(food))
        }
    }
}

/// "What kind of dish is it?" Templates, or copy an existing dish.
struct DishTemplatePicker: View {
    var onPick: (Food) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var search = ""

    private var matches: [Food] {
        let query = search.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return [] }
        return Catalog.allFoods.filter {
            $0.name.lowercased().contains(query) || ($0.localName?.lowercased().contains(query) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if search.isEmpty {
                    Section("What kind of dish is it?") {
                        ForEach(DishTemplate.all) { template in
                            Button {
                                onPick(template.makeFood())
                            } label: {
                                HStack(spacing: 12) {
                                    Text(template.emoji).font(.system(size: 28))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(template.name).font(.kid(16, weight: .heavy)).foregroundStyle(Palette.ink)
                                        Text(template.example).font(.kid(12, weight: .semibold)).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    Section("Copy a dish and make it yours") {
                        ForEach(matches.prefix(40)) { food in
                            Button {
                                var copy = food
                                copy.id = DishTemplate.newID()
                                onPick(copy)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(food.emoji).font(.system(size: 26))
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(food.name).font(.kid(15, weight: .heavy)).foregroundStyle(Palette.ink)
                                        if let pack = Catalog.package(of: food) {
                                            Text("\(pack.emoji) \(pack.name)").font(.kid(12, weight: .semibold)).foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                        }
                        if matches.isEmpty {
                            Text("No dish with that name yet. Clear the search and start from a template!")
                                .font(.kid(14, weight: .semibold))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .searchable(text: $search, prompt: "Or search dishes to copy (e.g. khichdi, borscht)")
            .navigationTitle("New Family Dish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

/// Edit every field of a family dish, with a live preview of the card and its superpowers.
struct FoodEditorView: View {
    @State var food: Food
    let isNew: Bool
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private var canSave: Bool {
        !food.name.trimmingCharacters(in: .whitespaces).isEmpty && !food.nutrients.isEmpty && !food.emoji.isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Spacer()
                        FoodCard(food: preview).frame(width: 150)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }

                Section("The dish") {
                    TextField("Name (e.g. Nani's Moong Dal)", text: $food.name)
                    TextField("What you call it at home (optional)", text: Binding(
                        get: { food.localName ?? "" },
                        set: { food.localName = $0.isEmpty ? nil : $0 }))
                    EmojiField(emoji: $food.emoji, suggestions: Self.foodEmojis)
                    TextField("A sentence for your child about it", text: $food.blurb, axis: .vertical)
                }

                Section {
                    NutrientToggles(title: "Big nutrients (macros)", nutrients: Nutrient.allCases.filter(\.isMacro), selected: $food.nutrients)
                    NutrientToggles(title: "Tiny helpers (micros)", nutrients: Nutrient.allCases.filter { !$0.isMacro }, selected: $food.nutrients)
                } header: {
                    Text("What's in it?")
                } footer: {
                    if food.isSometimes {
                        Text("Sometimes foods don't give superpowers in missions.")
                    } else {
                        Text("Superpowers: " + Benefit.allCases.filter(food.benefits.contains).map { "\($0.emoji) \($0.name)" }.joined(separator: ", "))
                    }
                }

                Section("Kind of dish") {
                    ForEach(FoodTag.allCases) { tag in
                        Toggle(tag.name, isOn: Binding(
                            get: { food.tags.contains(tag) },
                            set: { on in if on { food.tags.insert(tag) } else { food.tags.remove(tag) } }))
                    }
                    Toggle("Sometimes food (festival / party treat)", isOn: $food.isSometimes)
                }

                Section {
                    Picker("Diet", selection: $food.diet) {
                        ForEach(Diet.allCases) { Text($0.name).tag($0) }
                    }
                    ForEach(Allergen.allCases) { allergen in
                        Toggle("\(allergen.emoji)  Contains \(allergen.name.lowercased())", isOn: Binding(
                            get: { food.allergens.contains(allergen) },
                            set: { on in if on { food.allergens.insert(allergen) } else { food.allergens.remove(allergen) } }))
                    }
                } header: {
                    Text("Diet & allergens")
                } footer: {
                    Text("Used to keep this dish away from anyone it isn't safe for.")
                }

                if !isNew {
                    Section {
                        Button("Delete this dish", role: .destructive) {
                            store.deleteFamilyFood(food)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Family Dish" : "Edit Dish")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var saved = food
                        saved.name = saved.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        saved.blurb = saved.blurb.trimmingCharacters(in: .whitespacesAndNewlines)
                        if saved.blurb.isEmpty { saved.blurb = "A dish from our family's kitchen." }
                        store.saveFamilyFood(saved)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }

    private var preview: Food {
        var copy = food
        if copy.name.isEmpty { copy.name = "Your dish" }
        return copy
    }

    static let foodEmojis = ["🍛", "🍲", "🥘", "🍚", "🫓", "🥞", "🥗", "🥬", "🫘", "🥣", "🍜", "🥟", "🍳", "🐟", "🍗", "🧀", "🥛", "🍠", "🥕", "🍎", "🍌", "🥭", "🌽", "🍰", "🍪"]
}

// MARK: - Family Remedies (custom remedies)

struct FamilyRemediesEditor: View {
    @Environment(GameStore.self) private var store
    @State private var editing: Remedy?
    @State private var pickingTemplate = false

    var body: some View {
        List {
            Section {
                Button {
                    pickingTemplate = true
                } label: {
                    Label("Add a family remedy", systemImage: "plus.circle.fill")
                        .font(.kid(16, weight: .heavy))
                }
            } footer: {
                Text("Add the home remedies your family trusts, like Nani's kadha or Abuela's té de canela. Record a grandparent explaining it if you like. Family remedies are offered first in remedy missions.")
            }

            if !store.familyRemedies.isEmpty {
                Section("Our remedies") {
                    ForEach(store.familyRemedies) { remedy in
                        Button { editing = remedy } label: {
                            HStack(spacing: 12) {
                                Text(remedy.emoji).font(.system(size: 30))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(remedy.name).font(.kid(16, weight: .heavy)).foregroundStyle(Palette.ink)
                                    Text(remedy.treats.map(\.name).sorted().joined(separator: ", ") + (remedy.author.map { " · from \($0)" } ?? ""))
                                        .font(.kid(12, weight: .semibold))
                                        .foregroundStyle(.secondary)
                                        .lineLimit(1)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { store.familyRemedies[$0] }.forEach(store.deleteFamilyRemedy)
                    }
                }
            }
        }
        .navigationTitle("Our Family Remedies")
        .sheet(isPresented: $pickingTemplate) {
            RemedyTemplatePicker { remedy in
                pickingTemplate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { editing = remedy }
            }
        }
        .sheet(item: $editing) { remedy in
            RemedyEditorView(remedy: remedy, isNew: !store.familyRemedies.contains(remedy))
        }
    }
}

struct RemedyTemplatePicker: View {
    var onPick: (Remedy) -> Void
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section("What kind of remedy is it?") {
                    ForEach(RemedyTemplate.all) { template in
                        Button {
                            onPick(template.makeRemedy(author: store.elder))
                        } label: {
                            HStack(spacing: 12) {
                                Text(template.emoji).font(.system(size: 28))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(template.name).font(.kid(16, weight: .heavy)).foregroundStyle(Palette.ink)
                                    Text(template.example).font(.kid(12, weight: .semibold)).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("New Family Remedy")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

struct RemedyEditorView: View {
    @State var remedy: Remedy
    let isNew: Bool
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var recorder = VoiceRecorder()
    @State private var stepsText = ""

    private var canSave: Bool {
        !remedy.name.trimmingCharacters(in: .whitespaces).isEmpty && !remedy.treats.isEmpty && !steps.isEmpty
    }

    private var steps: [String] {
        stepsText.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("The remedy") {
                    TextField("Name (e.g. Nani's Ginger Kadha)", text: $remedy.name)
                    TextField("What you call it at home (optional)", text: Binding(
                        get: { remedy.localName ?? "" },
                        set: { remedy.localName = $0.isEmpty ? nil : $0 }))
                    EmojiField(emoji: $remedy.emoji, suggestions: Self.remedyEmojis)
                    TextField("Who taught it? (Nani, Abuela, Papa…)", text: Binding(
                        get: { remedy.author ?? "" },
                        set: { remedy.author = $0.isEmpty ? nil : $0 }))
                }

                Section {
                    ForEach(Ailment.allCases) { ailment in
                        Toggle("\(ailment.emoji)  \(ailment.name)", isOn: Binding(
                            get: { remedy.treats.contains(ailment) },
                            set: { on in if on { remedy.treats.insert(ailment) } else { remedy.treats.remove(ailment) } }))
                    }
                } header: {
                    Text("What does it help with?")
                }

                Section {
                    TextField("How it helps, in words a child understands", text: $remedy.howItHelps, axis: .vertical)
                    TextEditor(text: $stepsText)
                        .frame(minHeight: 110)
                    TextField("Safety note (optional)", text: Binding(
                        get: { remedy.caution ?? "" },
                        set: { remedy.caution = $0.isEmpty ? nil : $0 }), axis: .vertical)
                } header: {
                    Text("How to make it (one step per line)")
                } footer: {
                    Text("Steps are always shown as \"make it with a grown-up\", alongside when to see a doctor.")
                }

                Section {
                    Picker("Diet", selection: $remedy.diet) {
                        ForEach(Diet.allCases) { Text($0.name).tag($0) }
                    }
                    ForEach(Allergen.allCases) { allergen in
                        Toggle("\(allergen.emoji)  Contains \(allergen.name.lowercased())", isOn: Binding(
                            get: { remedy.allergens.contains(allergen) },
                            set: { on in if on { remedy.allergens.insert(allergen) } else { remedy.allergens.remove(allergen) } }))
                    }
                } header: {
                    Text("Diet & allergens")
                }

                Section {
                    RecordButton(recorder: recorder)
                    if let existing = remedy.audioFile, recorder.fileName == nil {
                        HStack {
                            Text("Saved recording").font(.kid(14, weight: .bold))
                            Spacer()
                            PlayVoiceButton(file: existing)
                        }
                    }
                } header: {
                    Text("Record it in their voice (optional)")
                }

                if !isNew {
                    Section {
                        Button("Delete this remedy", role: .destructive) {
                            store.deleteFamilyRemedy(remedy)
                            dismiss()
                        }
                    }
                }
            }
            .navigationTitle(isNew ? "New Family Remedy" : "Edit Remedy")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear { if stepsText.isEmpty { stepsText = remedy.steps.joined(separator: "\n") } }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        recorder.discard()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if recorder.isRecording { recorder.stop() }
                        var saved = remedy
                        saved.name = saved.name.trimmingCharacters(in: .whitespacesAndNewlines)
                        saved.steps = steps
                        if saved.howItHelps.trimmingCharacters(in: .whitespaces).isEmpty {
                            saved.howItHelps = "A remedy our family has trusted for years."
                        }
                        if let file = recorder.fileName { saved.audioFile = file }
                        store.saveFamilyRemedy(saved)
                        dismiss()
                    }
                    .disabled(!canSave || recorder.isRecording)
                }
            }
        }
    }

    static let remedyEmojis = ["🍵", "🫖", "🍋", "🫚", "🍯", "🌿", "🧂", "♨️", "🧊", "🥣", "🥛", "🥤", "🫙", "🌼", "🌱", "🧄"]
}

// MARK: - Shared editor pieces

/// Pick an emoji from suggestions, or type any emoji.
struct EmojiField: View {
    @Binding var emoji: String
    let suggestions: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Picture")
                Spacer()
                TextField("🍲", text: Binding(
                    get: { emoji },
                    set: { emoji = String($0.suffix(1)) }))
                    .multilineTextAlignment(.center)
                    .font(.system(size: 28))
                    .frame(width: 60)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(suggestions, id: \.self) { option in
                        Text(option)
                            .font(.system(size: 26))
                            .padding(4)
                            .background(Circle().fill(option == emoji ? Palette.mint : .clear))
                            .onTapGesture { emoji = option }
                    }
                }
            }
        }
    }
}

/// Tappable nutrient chips.
struct NutrientToggles: View {
    let title: String
    let nutrients: [Nutrient]
    @Binding var selected: [Nutrient]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.kid(14, weight: .heavy)).foregroundStyle(.secondary)
            FlowLayout(spacing: 6) {
                ForEach(nutrients) { nutrient in
                    let on = selected.contains(nutrient)
                    Text("\(nutrient.emoji) \(nutrient.name)")
                        .font(.kid(13, weight: .bold))
                        .foregroundStyle(Palette.ink)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(Capsule().fill(on ? (nutrient.isMacro ? Palette.peach : Palette.sky) : Color.white))
                        .overlay(Capsule().stroke(on ? Palette.ink.opacity(0.3) : Palette.lavender, lineWidth: 1.5))
                        .onTapGesture {
                            if let index = selected.firstIndex(of: nutrient) {
                                selected.remove(at: index)
                            } else {
                                selected.append(nutrient)
                            }
                        }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

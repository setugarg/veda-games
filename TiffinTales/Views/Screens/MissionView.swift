import SwiftUI

/// One bite-sized mission: the tricky spot → pick food or a remedy → the character gets out of it.
struct MissionView: View {
    let mission: Mission

    @Environment(GameStore.self) private var store
    @Environment(Router.self) private var router

    private enum Phase { case intro, playing, celebrating }

    @State private var phase: Phase = .intro
    @State private var mood: Mood
    @State private var tiffyLine = ""
    @State private var attempts = 0
    @State private var earnedStars = 0

    // Meal missions
    @State private var options: [Food] = []
    @State private var needs: [Benefit] = []
    @State private var plate: [Food] = []
    @State private var filled: Set<Benefit> = []
    @State private var lastResult: MealResult?
    @State private var eating = false
    @State private var detailFood: Food?

    // Remedy missions
    @State private var remedyChoices: [RemedyChoice] = []
    @State private var wrongPicks: Set<String> = []
    @State private var shakeID: String?
    @State private var shakeCount: CGFloat = 0
    @State private var soothedWith: Remedy?

    init(mission: Mission) {
        self.mission = mission
        _mood = State(initialValue: mission.stuckMood)
    }

    private var tint: Int { store.chapter(of: mission)?.tint ?? 0 }
    private var name: String { store.name }

    var body: some View {
        ZStack {
            PastelBackground(tint: tint)
            ScrollView {
                VStack(spacing: 16) {
                    stage
                    switch phase {
                    case .intro: intro
                    case .playing:
                        if let ailment = mission.ailment { remedyBoard(ailment) } else { mealBoard }
                    case .celebrating: celebration
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
            if phase == .celebrating { ConfettiView() }
        }
        .navigationTitle(mission.title)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $detailFood) { food in
            FoodDetailView(food: food).presentationDetents([.medium, .large])
        }
        .onAppear(perform: setUp)
        .onDisappear { Narrator.shared.stop() }
    }

    // MARK: Stage

    private var stage: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LinearGradient(colors: [Palette.soft(tint), .white], startPoint: .top, endPoint: .bottom))
                .shadow(color: Palette.ink.opacity(0.08), radius: 12, y: 6)

            Text(mission.scene)
                .font(.system(size: 54))
                .opacity(0.35)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .padding(18)

            if phase == .celebrating {
                Text(mission.successEmoji)
                    .font(.system(size: 60))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .padding(18)
                    .transition(.scale.combined(with: .opacity))
            }

            VStack(spacing: 10) {
                ZStack {
                    CharacterView(mood: mood, avatar: store.settings.avatar, size: 150)
                    if eating {
                        HStack(spacing: 4) {
                            ForEach(plate) { food in Text(food.emoji).font(.system(size: 34)) }
                        }
                        .transition(.asymmetric(insertion: .offset(y: 160).combined(with: .opacity),
                                                removal: .scale(scale: 0.1).combined(with: .opacity)))
                        .offset(y: 10)
                    }
                }
                if !needs.isEmpty {
                    FlowLayout(spacing: 8) {
                        ForEach(needs) { need in NeedChip(benefit: need, filled: filled.contains(need)) }
                    }
                }
                if let ailment = mission.ailment {
                    HStack(spacing: 6) {
                        Text(ailment.emoji)
                        Text(ailment.name).font(.kid(15))
                        if soothedWith != nil { Image(systemName: "checkmark").font(.system(size: 12, weight: .heavy)) }
                    }
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Capsule().fill(soothedWith == nil ? Palette.rose : Palette.mint))
                }
            }
            .padding(.vertical, 20)
        }
        .frame(minHeight: 300)
    }

    // MARK: Intro

    private var intro: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 10) {
                Text(mission.situation.personalized(name))
                    .font(.kid(19, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .frame(maxWidth: .infinity, alignment: .leading)
                SpeakButton(text: mission.situation.personalized(name))
            }
            .padding(18)
            .puffyCard()

            Button {
                Haptics.tap()
                withAnimation(.spring(response: 0.5, dampingFraction: 0.75)) { phase = .playing }
                speakIfEnabled(tiffyLine)
            } label: {
                Label("Open the tiffin!", systemImage: "sparkles")
            }
            .buttonStyle(SquishyButtonStyle(color: Palette.peachDeep))
        }
        .task {
            speakIfEnabled(mission.situation.personalized(name))
        }
    }

    // MARK: Meal board

    private var mealBoard: some View {
        VStack(spacing: 16) {
            TiffySays(text: tiffyLine, size: 54)

            plateRow

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 104), spacing: 12)], spacing: 12) {
                ForEach(options) { food in
                    FoodCard(food: food, selected: plate.contains(food), dimmed: eating) {
                        detailFood = food
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { toggle(food) }
                    .accessibilityAddTraits(.isButton)
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var plateRow: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                ForEach(0..<MissionEngine.plateSize, id: \.self) { slot in
                    ZStack {
                        Circle()
                            .fill(.white)
                            .overlay(Circle().stroke(Palette.lavender, style: StrokeStyle(lineWidth: 3, dash: plate.indices.contains(slot) ? [] : [6, 5])))
                            .frame(width: 62, height: 62)
                        if plate.indices.contains(slot) {
                            Text(plate[slot].emoji)
                                .font(.system(size: 32))
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .onTapGesture {
                        if plate.indices.contains(slot) { toggle(plate[slot]) }
                    }
                }
            }
            Spacer(minLength: 0)
            Button {
                eat()
            } label: {
                Label("Eat!", systemImage: "fork.knife")
            }
            .buttonStyle(SquishyButtonStyle(color: plate.isEmpty ? Palette.inkSoft.opacity(0.35) : Palette.mintDeep))
            .disabled(plate.isEmpty || eating)
        }
        .padding(14)
        .puffyCard(Palette.cream.opacity(0.9))
    }

    // MARK: Remedy board

    private func remedyBoard(_ ailment: Ailment) -> some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("What's happening?")
                        .font(.kid(16, weight: .heavy))
                        .foregroundStyle(Palette.inkSoft)
                    Spacer()
                    SpeakButton(text: ailment.whatsHappening, tint: Palette.roseDeep)
                }
                Text(ailment.whatsHappening)
                    .font(.kid(17, weight: .semibold))
                    .foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .puffyCard(Palette.rose.opacity(0.6))

            TiffySays(text: tiffyLine, size: 54)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(remedyChoices) { choice in
                    remedyCard(choice)
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func remedyCard(_ choice: RemedyChoice) -> some View {
        let wrong = wrongPicks.contains(choice.id)
        return Button {
            pick(choice)
        } label: {
            VStack(spacing: 6) {
                Text(choice.emoji).font(.system(size: 40))
                Text(choice.name)
                    .font(.kid(15))
                    .foregroundStyle(Palette.ink)
                    .multilineTextAlignment(.center)
                if let local = choice.remedy?.localName {
                    Text(local).font(.kid(12, weight: .semibold)).foregroundStyle(Palette.inkSoft)
                }
                if let remedy = choice.remedy, let pack = Catalog.package(of: remedy), !pack.isCore {
                    Text("\(pack.emoji) \(pack.name)")
                        .font(.kid(10, weight: .bold))
                        .foregroundStyle(Palette.inkSoft)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
                if choice.treat != nil {
                    Text("Sometimes food")
                        .font(.kid(10, weight: .heavy))
                        .foregroundStyle(Palette.inkSoft)
                        .padding(.horizontal, 8).padding(.vertical, 3)
                        .background(Capsule().fill(Palette.butter))
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 150)
            .puffyCard(Palette.soft(Palette.tint(for: choice.id)), radius: 22)
            .opacity(wrong ? 0.4 : 1)
            .overlay(alignment: .topTrailing) {
                if wrong {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Palette.roseDeep)
                        .padding(8)
                }
            }
            .modifier(Shake(animatableData: shakeID == choice.id ? shakeCount : 0))
        }
        .buttonStyle(PressableStyle())
        .disabled(wrong || soothedWith != nil)
    }

    // MARK: Celebration

    private var celebration: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                StarsView(count: earnedStars, size: 34)
                    .scaleEffect(phase == .celebrating ? 1 : 0.2)
                    .animation(.spring(response: 0.5, dampingFraction: 0.45).delay(0.2), value: phase)
                HStack(alignment: .top) {
                    Text(mission.successText.personalized(name))
                        .font(.kid(20, weight: .heavy))
                        .foregroundStyle(Palette.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    SpeakButton(text: mission.successText.personalized(name), tint: Palette.mintDeep)
                }
            }
            .padding(18)
            .puffyCard()

            if let result = lastResult { mealLesson(result) }
            if let remedy = soothedWith { RemedyLessonCard(remedy: remedy, ailment: mission.ailment) }

            HStack(spacing: 12) {
                Button {
                    router.path.removeLast()
                } label: {
                    Label("Map", systemImage: "map.fill")
                }
                .buttonStyle(SquishyButtonStyle(color: Palette.lavenderDeep))

                if let next = store.nextMission(after: mission) {
                    Button {
                        Haptics.tap()
                        router.play(next)
                    } label: {
                        Label("Next", systemImage: "arrow.right")
                    }
                    .buttonStyle(SquishyButtonStyle(color: Palette.mintDeep))
                }
            }
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func mealLesson(_ result: MealResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What helped?")
                .font(.kid(18, weight: .heavy))
                .foregroundStyle(Palette.ink)
            ForEach(Array(result.sources.enumerated()), id: \.offset) { _, source in
                HStack(alignment: .top, spacing: 10) {
                    Text(source.food.emoji).font(.system(size: 28))
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(source.food.name) gave \(source.benefit.emoji) \(source.benefit.name)")
                            .font(.kid(15))
                            .foregroundStyle(Palette.ink)
                        FlowLayout(spacing: 6) {
                            ForEach(source.nutrients) { NutrientChip(nutrient: $0, compact: true) }
                        }
                    }
                }
                .onTapGesture { detailFood = source.food }
            }
            ForEach(result.treatsEaten) { treat in
                Text("\(treat.emoji) \(treat.name) didn't help this time. It's a sometimes food: fun for parties, not for tricky spots!")
                    .font(.kid(14, weight: .semibold))
                    .foregroundStyle(Palette.inkSoft)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .puffyCard(Palette.mint.opacity(0.7))
    }

    // MARK: Logic

    private func setUp() {
        guard options.isEmpty && remedyChoices.isEmpty else { return }
        var rng = SystemRandomNumberGenerator()
        let pantry = store.pantry
        if let ailment = mission.ailment {
            remedyChoices = MissionEngine.remedyChoices(for: ailment, pantry: pantry, using: &rng)
            tiffyLine = "Which home remedy will help \(name)'s \(ailment.name.lowercased())? Tap one!"
        } else {
            options = MissionEngine.mealOptions(for: mission, pantry: pantry, allowedDiet: store.settings.diet,
                                                familyAllergies: store.settings.allergies, using: &rng)
            needs = MissionEngine.achievableNeeds(for: mission, options: options)
            let needText = needs.map { "\($0.emoji) \($0.name)" }.joined(separator: ", ")
            var line = "\(name) needs \(needText). Pick up to 3 foods that show these powers!"
            if let avoid = mission.avoid {
                line += " Remember: NO \(avoid.name.lowercased()) \(avoid.emoji)!"
            }
            tiffyLine = line
        }
    }

    private func toggle(_ food: Food) {
        guard !eating else { return }
        Haptics.tap()
        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
            if let index = plate.firstIndex(of: food) {
                plate.remove(at: index)
            } else if plate.count < MissionEngine.plateSize {
                plate.append(food)
            } else {
                tiffyLine = "The plate is full! Tap a food on the plate to take it off."
            }
        }
    }

    private func eat() {
        guard !plate.isEmpty else { return }
        attempts += 1
        let result = MissionEngine.evaluate(plate: plate, needs: needs, avoid: mission.avoid)

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) { eating = true }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 700_000_000)
            withAnimation(.easeIn(duration: 0.3)) { eating = false }
            // Fill each covered need one by one, so the cause and effect is visible.
            for need in needs where result.covered.contains(need) && !filled.contains(need) {
                try? await Task.sleep(nanoseconds: 280_000_000)
                Haptics.tap()
                withAnimation { _ = filled.insert(need) }
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
            finishMeal(result)
        }
    }

    private func finishMeal(_ result: MealResult) {
        lastResult = result
        if result.success {
            earnedStars = MissionEngine.stars(for: result, attempts: attempts)
            store.completeMeal(mission, stars: earnedStars, plate: plate)
            Haptics.success()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                mood = .excited
                phase = .celebrating
            }
            speakIfEnabled(mission.successText.personalized(name))
            return
        }

        Haptics.oops()
        withAnimation { filled = [] }
        if let allergic = result.allergenFoods.first, let avoid = mission.avoid {
            tiffyLine = "Uh-oh! \(allergic.emoji) \(allergic.name) has \(avoid.name.lowercased()). Our friend can't eat that. Always check! Swap it for something safe."
            withAnimation { mood = .worried }
        } else {
            let got = result.covered.isEmpty ? "" : "Yum! That gave " +
                needs.filter(result.covered.contains).map { "\($0.emoji) \($0.name)" }.joined(separator: " and ") + ". "
            let missing = result.missing.first!
            var line = got + "But \(name) still needs \(missing.emoji) \(missing.name). \(missing.hint) Look for \(missing.emoji) on the cards!"
            if !result.treatsEaten.isEmpty {
                line += " (Sometimes foods don't give powers.)"
            }
            tiffyLine = line
            withAnimation { mood = result.covered.isEmpty ? mission.stuckMood : .tired }
        }
        speakIfEnabled(tiffyLine)
    }

    private func pick(_ choice: RemedyChoice) {
        guard let ailment = mission.ailment else { return }
        attempts += 1
        switch MissionEngine.evaluate(choice: choice, for: ailment) {
        case .soothed(let remedy):
            earnedStars = MissionEngine.remedyStars(attempts: attempts)
            store.completeRemedy(mission, stars: earnedStars, remedy: remedy)
            Haptics.success()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                soothedWith = remedy
                mood = .happy
            }
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 600_000_000)
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) {
                    mood = .excited
                    phase = .celebrating
                }
                speakIfEnabled(mission.successText.personalized(name))
            }
        case .wrongRemedy(let remedy, let meantFor):
            tiffyLine = "\(remedy.emoji) \(remedy.name) is great for \(meantFor.emoji) \(meantFor.name.lowercased()), but not for a \(ailment.name.lowercased()). Try another!"
            wrong(choice)
        case .treat(let food):
            tiffyLine = "\(food.emoji) \(food.name) is a sometimes food. It won't make a \(ailment.name.lowercased()) better. Try a home remedy!"
            wrong(choice)
        }
    }

    private func wrong(_ choice: RemedyChoice) {
        Haptics.oops()
        shakeID = choice.id
        withAnimation(.linear(duration: 0.4)) { shakeCount += 1 }
        wrongPicks.insert(choice.id)
        speakIfEnabled(tiffyLine)
    }

    private func speakIfEnabled(_ text: String) {
        if store.settings.readAloud { Narrator.shared.speak(text) }
    }
}

/// Explains the remedy that worked, with steps and safety notes.
struct RemedyLessonCard: View {
    let remedy: Remedy
    let ailment: Ailment?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text(remedy.emoji).font(.system(size: 40))
                VStack(alignment: .leading, spacing: 2) {
                    Text(remedy.name).font(.kid(20, weight: .heavy)).foregroundStyle(Palette.ink)
                    if let local = remedy.localName {
                        Text(local).font(.kid(14, weight: .semibold)).foregroundStyle(Palette.inkSoft)
                    }
                    if let pack = Catalog.package(of: remedy) {
                        Text("\(pack.emoji) \(pack.name)").font(.kid(12, weight: .bold)).foregroundStyle(Palette.inkSoft)
                    }
                }
                Spacer()
                SpeakButton(text: remedy.howItHelps + " " + remedy.steps.joined(separator: " "), tint: Palette.sageDeep)
            }
            Text("How it helps").font(.kid(15, weight: .heavy)).foregroundStyle(Palette.inkSoft)
            Text(remedy.howItHelps).font(.kid(16, weight: .semibold)).foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("Make it with a grown-up").font(.kid(15, weight: .heavy)).foregroundStyle(Palette.inkSoft)
            ForEach(Array(remedy.steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1)")
                        .font(.kid(13, weight: .heavy))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Palette.sageDeep))
                    Text(step).font(.kid(15, weight: .semibold)).foregroundStyle(Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            if let caution = remedy.caution {
                Label(caution, systemImage: "exclamationmark.triangle.fill")
                    .font(.kid(14, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Palette.butter))
            }
            if let ailment {
                Label(ailment.grownUpNote, systemImage: "person.2.fill")
                    .font(.kid(14, weight: .bold))
                    .foregroundStyle(Palette.ink)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 14).fill(Palette.sky))
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .puffyCard(Palette.sage.opacity(0.8))
    }
}

/// Side-to-side wiggle for a wrong pick.
struct Shake: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 8 * sin(animatableData * .pi * 4), y: 0))
    }
}

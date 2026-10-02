import SwiftUI

/// "Dadi says" + "Science says": one piece of grandparent food knowledge.
struct WisdomCardView: View {
    let wisdom: Wisdom
    @Environment(GameStore.self) private var store

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                Text(wisdom.emoji).font(.system(size: 40))
                VStack(alignment: .leading, spacing: 2) {
                    Text(wisdom.title).font(.kid(20, weight: .heavy)).foregroundStyle(Palette.ink)
                    Text("\(wisdom.kind.emoji) \(wisdom.kind.name) · \(wisdom.origin)")
                        .font(.kid(12, weight: .bold))
                        .foregroundStyle(Palette.inkSoft)
                }
                Spacer()
                SpeakButton(text: "\(store.elder) says: \(wisdom.grandmaSays) Science says: \(wisdom.scienceSays)",
                            tint: Palette.butterDeep)
            }

            HStack(spacing: 10) {
                Text(wisdom.answer.emoji).font(.system(size: 26))
                Text(wisdom.answer.name).font(.kid(16, weight: .heavy)).foregroundStyle(Palette.ink)
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 14).fill(.white.opacity(0.8)))

            section(title: "👵🏽 \(store.elder) says", text: wisdom.grandmaSays, color: Palette.peach)
            if let saying = wisdom.saying {
                Text("“\(saying)”")
                    .font(.kid(16, weight: .heavy))
                    .italic()
                    .foregroundStyle(Palette.ink)
                    .padding(.horizontal, 6)
            }
            section(title: "🔬 Science says", text: wisdom.scienceSays, color: Palette.sky)

            Text("\(wisdom.evidence.emoji)  \(wisdom.evidence.label)")
                .font(.kid(13, weight: .heavy))
                .foregroundStyle(Palette.ink)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(Capsule().fill(wisdom.evidence == .tradition ? Palette.rose : Palette.mint))
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .puffyCard(Palette.butter.opacity(0.85))
    }

    private func section(title: String, text: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title).font(.kid(14, weight: .heavy)).foregroundStyle(Palette.inkSoft)
            Text(text).font(.kid(15, weight: .semibold)).foregroundStyle(Palette.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 14).fill(color))
    }
}

/// The family's collected food wisdom: their own tips and recordings, grandma
/// combos found on plates, wisdom cards learned in missions, and questions to ask elders.
struct WisdomBookView: View {
    @Environment(GameStore.self) private var store
    @State private var selected: Wisdom?
    @State private var interviewQuestion: InterviewQuestion?

    var body: some View {
        ZStack {
            PastelBackground(tint: 4)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    TiffySays(text: "Grandparents carry recipes in their heads, not in books. Let's collect them all, before they're forgotten!", size: 50)
                    familySection
                    askSection
                    combosSection
                    ForEach(WisdomKind.allCases.filter { kind in cards.contains { $0.kind == kind } }) { kind in
                        kindSection(kind)
                    }
                }
                .padding(16)
                .frame(maxWidth: 680)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationTitle("Wisdom Book")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $selected) { wisdom in
            ScrollView { WisdomCardView(wisdom: wisdom).padding(16) }
                .background(Palette.cream.ignoresSafeArea())
                .presentationDetents([.medium, .large])
        }
        .sheet(item: $interviewQuestion) { item in
            InterviewSheet(question: item.text)
        }
    }

    private var cards: [Wisdom] { Catalog.familiarWisdom(for: store.settings) }

    private var familySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            header("💛 From Our Family", subtitle: store.familyTips.isEmpty
                   ? "Nothing yet! Ask a grown-up to add a family tip, or interview a grandparent below."
                   : "\(store.familyTips.count) saved")
            ForEach(store.familyTips) { tip in FamilyTipRow(tip: tip) }
        }
    }

    private var askSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            header("🎙️ Ask Your Elders", subtitle: "Ask a grandparent one of these, and record the answer.")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(WisdomContent.elderQuestions, id: \.self) { question in
                        let asked = store.familyTips.contains { $0.title == question }
                        Button {
                            interviewQuestion = InterviewQuestion(text: question)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(asked ? "✅" : "🎙️").font(.system(size: 24))
                                Text(question)
                                    .font(.kid(14, weight: .bold))
                                    .foregroundStyle(Palette.ink)
                                    .multilineTextAlignment(.leading)
                                Spacer(minLength: 0)
                            }
                            .padding(12)
                            .frame(width: 190, height: 150, alignment: .topLeading)
                            .puffyCard(asked ? Palette.mint : .white, radius: 20)
                        }
                        .buttonStyle(PressableStyle())
                    }
                }
                .padding(.vertical, 6)
            }
        }
    }

    private var combosSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            header("✨ Grandma Combos", subtitle: "Put these together on a plate in a mission to discover them.")
            ForEach(WisdomContent.combos) { combo in
                let found = store.progress.discoveredCombos.contains(combo.id)
                HStack(alignment: .top, spacing: 12) {
                    Text(found ? combo.emoji : "❔").font(.system(size: 30))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(combo.title).font(.kid(15, weight: .heavy)).foregroundStyle(Palette.ink)
                        Text(found ? combo.explanation : "Not discovered yet")
                            .font(.kid(13, weight: .semibold))
                            .foregroundStyle(Palette.inkSoft)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 0)
                }
                .padding(12)
                .puffyCard(found ? Palette.butter : Color.white.opacity(0.7), radius: 18)
            }
        }
    }

    private func kindSection(_ kind: WisdomKind) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            header("\(kind.emoji) \(kind.name)", subtitle: nil)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150), spacing: 12)], spacing: 12) {
                ForEach(cards.filter { $0.kind == kind }) { wisdom in
                    let learned = store.progress.learnedWisdom.contains(wisdom.id)
                    Button {
                        if learned { selected = wisdom }
                    } label: {
                        VStack(spacing: 6) {
                            Text(learned ? wisdom.emoji : "❔").font(.system(size: 34))
                            Text(learned ? wisdom.title : "Learn it in a mission")
                                .font(.kid(14, weight: .heavy))
                                .foregroundStyle(Palette.ink)
                                .multilineTextAlignment(.center)
                            Text(wisdom.origin)
                                .font(.kid(11, weight: .bold))
                                .foregroundStyle(Palette.inkSoft)
                                .multilineTextAlignment(.center)
                        }
                        .padding(12)
                        .frame(maxWidth: .infinity, minHeight: 130)
                        .puffyCard(learned ? Palette.butter : Color.white.opacity(0.7), radius: 20)
                    }
                    .buttonStyle(PressableStyle())
                }
            }
        }
    }

    private func header(_ title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title).font(.kid(20, weight: .heavy)).foregroundStyle(Palette.ink)
            if let subtitle {
                Text(subtitle).font(.kid(13, weight: .semibold)).foregroundStyle(Palette.inkSoft)
            }
        }
    }
}

struct InterviewQuestion: Identifiable {
    let text: String
    var id: String { text }
}

/// A family tip or recorded story, with playback.
struct FamilyTipRow: View {
    let tip: FamilyTip

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(tip.kind.emoji)
                .font(.system(size: 26))
                .frame(width: 46, height: 46)
                .background(Circle().fill(Palette.butter))
            VStack(alignment: .leading, spacing: 4) {
                Text(tip.title).font(.kid(15, weight: .heavy)).foregroundStyle(Palette.ink)
                    .fixedSize(horizontal: false, vertical: true)
                if !tip.text.isEmpty {
                    Text(tip.text).font(.kid(14, weight: .semibold)).foregroundStyle(Palette.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Text("— \(tip.author)")
                    .font(.kid(12, weight: .heavy))
                    .foregroundStyle(Palette.inkSoft)
            }
            Spacer(minLength: 0)
            if let file = tip.audioFile {
                PlayVoiceButton(file: file)
            } else if !tip.text.isEmpty {
                SpeakButton(text: "\(tip.author) says: \(tip.title). \(tip.text)", tint: Palette.butterDeep)
            }
        }
        .padding(14)
        .puffyCard(.white, radius: 20)
    }
}

/// Interview a grandparent outside the story (from the Wisdom Book).
struct InterviewSheet: View {
    let question: String
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var recorder = VoiceRecorder()
    @State private var who = ""
    @State private var note = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .bottom) {
                        ElderView(avatar: store.settings.avatar, size: 90)
                        Text("“\(question)”")
                            .font(.kid(20, weight: .heavy))
                            .foregroundStyle(Palette.ink)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Text("Who are you asking?").font(.kid(14, weight: .heavy)).foregroundStyle(Palette.inkSoft)
                    FlowLayout(spacing: 8) {
                        ForEach(MissionView.elderNames(store.elder), id: \.self) { name in
                            Text(name)
                                .font(.kid(14, weight: .bold))
                                .foregroundStyle(Palette.ink)
                                .padding(.horizontal, 12).padding(.vertical, 7)
                                .background(Capsule().fill(who == name ? Palette.mint : .white))
                                .overlay(Capsule().stroke(who == name ? Palette.mintDeep : Palette.lavender, lineWidth: 2))
                                .onTapGesture { who = name }
                        }
                    }
                    RecordButton(recorder: recorder)
                    TextField("Or type what they said (a grown-up can help)", text: $note, axis: .vertical)
                        .font(.kid(15, weight: .semibold))
                        .padding(12)
                        .background(RoundedRectangle(cornerRadius: 14).fill(.white))
                }
                .padding(20)
            }
            .background(Palette.cream.ignoresSafeArea())
            .navigationTitle("Ask Your Elders")
            .navigationBarTitleDisplayMode(.inline)
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
                        store.addFamilyTip(FamilyTip(author: who, kind: .story, title: question,
                                                     text: note.trimmingCharacters(in: .whitespacesAndNewlines),
                                                     audioFile: recorder.fileName))
                        dismiss()
                    }
                    .disabled(recorder.fileName == nil && note.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear { if who.isEmpty { who = store.elder } }
        }
    }
}

/// Grown-ups add the family's own knowledge: what goes with what, remedies,
/// seasonal habits. Each tip can carry a grandparent's recorded voice.
struct FamilyWisdomEditor: View {
    @Environment(GameStore.self) private var store
    @State private var adding = false

    var body: some View {
        List {
            Section {
                Button {
                    adding = true
                } label: {
                    Label("Add a family tip or remedy", systemImage: "plus.circle.fill")
                        .font(.kid(16, weight: .heavy))
                }
            } footer: {
                Text("Share what your parents and grandparents taught you: which foods go together, what to eat in which season, and the home remedies your family trusts. Your child sees these in the Wisdom Book, and Tiffy shares them on the home screen. Recordings stay on this device.")
            }

            if !store.familyTips.isEmpty {
                Section("Saved") {
                    ForEach(store.familyTips) { tip in
                        VStack(alignment: .leading, spacing: 3) {
                            Text("\(tip.kind.emoji) \(tip.title)").font(.kid(15, weight: .heavy))
                            if !tip.text.isEmpty {
                                Text(tip.text).font(.kid(13, weight: .regular)).foregroundStyle(.secondary)
                            }
                            Text("— \(tip.author)\(tip.audioFile == nil ? "" : " · 🎙️ recording")")
                                .font(.kid(12, weight: .bold)).foregroundStyle(Palette.lavenderDeep)
                        }
                    }
                    .onDelete { offsets in
                        offsets.map { store.familyTips[$0] }.forEach(store.deleteFamilyTip)
                    }
                }
            }
        }
        .navigationTitle("Our Family's Wisdom")
        .sheet(isPresented: $adding) { AddFamilyTipView() }
    }
}

struct AddFamilyTipView: View {
    @Environment(GameStore.self) private var store
    @Environment(\.dismiss) private var dismiss
    @State private var recorder = VoiceRecorder()
    @State private var author = ""
    @State private var kind: WisdomKind = .pairing
    @State private var title = ""
    @State private var text = ""

    private var examples: String {
        switch kind {
        case .pairing: return "e.g. “Always eat kadhi with khichdi” or “Lemon on every dal”"
        case .preparation: return "e.g. “Soak the moong overnight before making chilla”"
        case .season: return "e.g. “Bajra in winter, jowar and chaas in summer”"
        case .afterMeal: return "e.g. “A piece of gur after lunch”"
        case .balance: return "e.g. “Every plate gets a salad and a bowl of curd”"
        case .timing: return "e.g. “Soaked almonds first thing in the morning”"
        case .remedy: return "e.g. “Ajwain-hing on the tummy for gas”"
        case .story: return "e.g. “What Nani ate on festival days as a child”"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Who taught this?") {
                    TextField("Dadi, Nani, Ba, Aaji, Paati, Papa…", text: $author)
                }
                Section {
                    Picker("Kind of wisdom", selection: $kind) {
                        ForEach(WisdomKind.allCases) { Text("\($0.emoji) \($0.name)").tag($0) }
                    }
                    TextField("The tip", text: $title, axis: .vertical)
                    TextField("Why? How? (optional)", text: $text, axis: .vertical)
                } header: {
                    Text("The wisdom")
                } footer: {
                    Text(examples)
                }
                Section {
                    RecordButton(recorder: recorder)
                } header: {
                    Text("Record it in their voice (optional)")
                } footer: {
                    Text("Grandchildren love hearing it from Dadi or Nani themselves.")
                }
            }
            .navigationTitle("New Family Tip")
            .navigationBarTitleDisplayMode(.inline)
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
                        let who = author.trimmingCharacters(in: .whitespaces)
                        store.addFamilyTip(FamilyTip(author: who.isEmpty ? store.elder : who, kind: kind,
                                                     title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                                                     text: text.trimmingCharacters(in: .whitespacesAndNewlines),
                                                     audioFile: recorder.fileName))
                        dismiss()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

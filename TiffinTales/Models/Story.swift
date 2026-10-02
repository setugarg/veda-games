import Foundation

/// How the character looks while stuck, and while celebrating.
enum Mood: String, Codable {
    case happy, sleepy, worried, sick, tired, excited
}

/// A bite-sized mission inside a chapter.
struct Mission: Identifiable, Hashable {
    enum Kind: Hashable {
        /// Build a plate that gives these superpowers.
        case meal(needs: [Benefit], avoid: Allergen?)
        /// Pick the right home remedy.
        case remedy(Ailment)
        /// Answer a grandparent's kitchen-wisdom question (culture-specific when possible).
        case wisdom(WisdomTopic)
        /// Go and ask a real grandparent or parent, and record their answer.
        case askElder(question: String)
    }

    let id: String
    let title: String
    /// Scene props drawn around the character.
    let scene: String
    /// The tricky situation. `{name}` is replaced with the child's chosen name.
    let situation: String
    let kind: Kind
    let stuckMood: Mood
    /// What the character can do once they've eaten well.
    let successText: String
    let successEmoji: String

    var needs: [Benefit] {
        if case let .meal(needs, _) = kind { return needs }
        return []
    }

    var ailment: Ailment? {
        if case let .remedy(ailment) = kind { return ailment }
        return nil
    }

    var wisdomTopic: WisdomTopic? {
        if case let .wisdom(topic) = kind { return topic }
        return nil
    }

    var elderQuestion: String? {
        if case let .askElder(question) = kind { return question }
        return nil
    }

    var avoid: Allergen? {
        if case let .meal(_, avoid) = kind { return avoid }
        return nil
    }

    static func == (lhs: Mission, rhs: Mission) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct Chapter: Identifiable, Hashable {
    let id: String
    let number: Int
    let title: String
    let emoji: String
    let intro: String
    /// Index into the pastel palette used for the chapter's backdrop.
    let tint: Int
    let missions: [Mission]

    static func == (lhs: Chapter, rhs: Chapter) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension String {
    func personalized(_ name: String, elder: String = "Grandma") -> String {
        replacingOccurrences(of: "{name}", with: name)
            .replacingOccurrences(of: "{elder}", with: elder)
    }
}

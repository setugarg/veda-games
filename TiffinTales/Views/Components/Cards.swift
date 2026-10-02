import SwiftUI

/// A dish card in the mission grid.
struct FoodCard: View {
    let food: Food
    var selected: Bool = false
    var dimmed: Bool = false
    var onInfo: () -> Void = {}

    var body: some View {
        let tint = Palette.tint(for: food.id)
        VStack(spacing: 6) {
            Text(food.emoji)
                .font(.system(size: 40))
                .frame(height: 48)
            Text(food.name)
                .font(.kid(13))
                .foregroundStyle(Palette.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .frame(minHeight: 34)
            if food.isSometimes {
                Text("Sometimes food")
                    .font(.kid(10, weight: .heavy))
                    .foregroundStyle(Palette.inkSoft)
                    .padding(.horizontal, 8).padding(.vertical, 3)
                    .background(Capsule().fill(Palette.butter))
            } else {
                HStack(spacing: 2) {
                    ForEach(Benefit.allCases.filter(food.benefits.contains).prefix(4)) { benefit in
                        Text(benefit.emoji).font(.system(size: 13))
                    }
                }
                .frame(height: 18)
            }
            if !food.allergens.isEmpty {
                HStack(spacing: 2) {
                    ForEach(food.allergens.sorted { $0.rawValue < $1.rawValue }) { allergen in
                        Text(allergen.emoji).font(.system(size: 10))
                    }
                }
                .padding(.horizontal, 6).padding(.vertical, 2)
                .background(Capsule().fill(.white.opacity(0.7)))
                .accessibilityLabel("Contains " + food.allergens.map(\.name).joined(separator: ", "))
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, minHeight: 150)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Palette.soft(tint))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(selected ? Palette.deep(tint) : .clear, lineWidth: 4)
        )
        .overlay(alignment: .topTrailing) {
            Button(action: onInfo) {
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.inkSoft.opacity(0.7))
                    .padding(8)
            }
            .accessibilityLabel("What's inside \(food.name)")
        }
        .overlay(alignment: .topLeading) {
            if selected {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Palette.mintDeep)
                    .background(Circle().fill(.white))
                    .padding(6)
                    .transition(.scale)
            }
        }
        .scaleEffect(selected ? 1.04 : 1)
        .opacity(dimmed ? 0.45 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selected)
    }
}

/// A need chip that fills up when the plate provides it.
struct NeedChip: View {
    let benefit: Benefit
    var filled: Bool

    var body: some View {
        HStack(spacing: 6) {
            Text(benefit.emoji)
            Text(benefit.name)
                .font(.kid(14))
            if filled {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .heavy))
                    .transition(.scale)
            }
        }
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule().fill(filled ? Palette.mint : .white)
        )
        .overlay(
            Capsule().stroke(filled ? Palette.mintDeep : Palette.lavender, lineWidth: 2)
        )
        .scaleEffect(filled ? 1.06 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.55), value: filled)
    }
}

struct NutrientChip: View {
    let nutrient: Nutrient
    var compact = false

    var body: some View {
        HStack(spacing: 4) {
            Text(nutrient.emoji)
            Text(nutrient.name).font(.kid(compact ? 12 : 14, weight: .semibold))
        }
        .foregroundStyle(Palette.ink)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Capsule().fill(nutrient.isMacro ? Palette.peach : Palette.sky))
    }
}

struct StarsView: View {
    let count: Int
    var size: CGFloat = 18
    var total: Int = 3

    var body: some View {
        HStack(spacing: 2) {
            ForEach(0..<total, id: \.self) { i in
                Image(systemName: i < count ? "star.fill" : "star")
                    .font(.system(size: size, weight: .bold))
                    .foregroundStyle(i < count ? Palette.butterDeep : Palette.inkSoft.opacity(0.3))
            }
        }
        .accessibilityLabel("\(count) of \(total) stars")
    }
}

/// Simple wrapping layout for chips.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0, y: CGFloat = 0, rowHeight: CGFloat = 0, widest: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                y += rowHeight + spacing
                x = 0
                rowHeight = 0
            }
            x += size.width + spacing
            widest = max(widest, x - spacing)
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: min(widest, maxWidth), height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX, y = bounds.minY, rowHeight: CGFloat = 0
        for view in subviews {
            let size = view.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                y += rowHeight + spacing
                x = bounds.minX
                rowHeight = 0
            }
            view.place(at: CGPoint(x: x, y: y), proposal: ProposedViewSize(size))
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

/// Pastel confetti burst for successes.
struct ConfettiView: View {
    private struct Piece {
        let x: Double, speed: Double, drift: Double, spin: Double, size: Double, color: Color, delay: Double
    }

    @State private var start = Date()
    private let pieces: [Piece] = (0..<70).map { _ in
        Piece(x: .random(in: 0...1), speed: .random(in: 140...260), drift: .random(in: -40...40),
              spin: .random(in: 1...4), size: .random(in: 6...12),
              color: Palette.deep.randomElement()!, delay: .random(in: 0...0.6))
    }

    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSince(start)
                for piece in pieces {
                    let local = t - piece.delay
                    guard local > 0 else { continue }
                    let y = -20 + local * piece.speed
                    guard y < size.height + 20 else { continue }
                    let x = piece.x * size.width + sin(local * piece.spin) * piece.drift
                    var ctx = context
                    ctx.translateBy(x: x, y: y)
                    ctx.rotate(by: .radians(local * piece.spin * 2))
                    let rect = CGRect(x: -piece.size / 2, y: -piece.size / 4, width: piece.size, height: piece.size / 2)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(piece.color))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
        .onAppear { start = Date() }
    }
}

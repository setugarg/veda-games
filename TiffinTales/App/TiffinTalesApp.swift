import SwiftUI

@main
struct TiffinTalesApp: App {
    @State private var store = GameStore()
    @State private var router = Router()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
                .environment(router)
                .preferredColorScheme(.light)
                .tint(Palette.lavenderDeep)
        }
    }
}

enum Route: Hashable {
    case chapter(Chapter)
    case mission(Mission)
    case nutrientBook
    case remedyBook
    case pantry
}

@Observable
final class Router {
    var path: [Route] = []

    func play(_ mission: Mission) {
        // Replace a finished mission with the next one, keeping the map underneath.
        if case .mission = path.last { path.removeLast() }
        path.append(.mission(mission))
    }

    func popToRoot() { path.removeAll() }
}

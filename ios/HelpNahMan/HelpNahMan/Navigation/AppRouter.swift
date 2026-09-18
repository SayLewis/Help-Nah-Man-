import Foundation
import Observation
import SwiftUI

enum AppTab: String, CaseIterable, Identifiable, Hashable {
    case home
    case discover
    case saved
    case about

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: "Home"
        case .discover: "Discover"
        case .saved: "Saved"
        case .about: "About"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "newspaper.fill"
        case .discover: "magnifyingglass"
        case .saved: "bookmark.fill"
        case .about: "heart.text.square.fill"
        }
    }
}

enum AppRoute: Hashable {
    case notice(UUID)
}

enum SheetDestination: Identifiable, Hashable {
    case composer(NoticeKind?)
    case participation(UUID)

    var id: String {
        switch self {
        case .composer: "composer"
        case .participation(let id): "participation-\(id.uuidString)"
        }
    }
}

@MainActor
@Observable
final class AppRouter {
    var selectedTab: AppTab = .home
    var homePath: [AppRoute] = []
    var discoverPath: [AppRoute] = []
    var savedPath: [AppRoute] = []
    var aboutPath: [AppRoute] = []
    var sheet: SheetDestination?
    var discoverFilter: NoticeKind?

    func show(_ noticeID: UUID, in tab: AppTab? = nil) {
        let destinationTab = tab ?? selectedTab
        selectedTab = destinationTab
        switch destinationTab {
        case .home: homePath.append(.notice(noticeID))
        case .discover: discoverPath.append(.notice(noticeID))
        case .saved: savedPath.append(.notice(noticeID))
        case .about:
            selectedTab = .home
            homePath.append(.notice(noticeID))
        }
    }

    func openDiscover(kind: NoticeKind?) {
        discoverFilter = kind
        selectedTab = .discover
        discoverPath.removeAll()
    }

    func handle(url: URL) -> OpenURLAction.Result {
        guard url.scheme == "helpnahman" else { return .systemAction }
        let parts = url.pathComponents.filter { $0 != "/" }
        if url.host == "notice", let value = parts.first, let id = UUID(uuidString: value) {
            show(id, in: .home)
        } else if url.host == "post" {
            sheet = .composer(nil)
        } else if url.host == "discover" {
            openDiscover(kind: nil)
        }
        return .handled
    }

    func handle(_ action: SystemIntentAction) {
        switch action {
        case .openCategory(let kind): openDiscover(kind: kind)
        case .compose(let kind): sheet = .composer(kind)
        case .openNotice(let id): show(id, in: .home)
        }
    }
}

enum SystemIntentAction: Equatable, Sendable {
    case openCategory(NoticeKind?)
    case compose(NoticeKind?)
    case openNotice(UUID)
}

struct IntentHandoff: Identifiable, Equatable, Sendable {
    let id = UUID()
    let action: SystemIntentAction
}

@MainActor
@Observable
final class AppIntentRouter {
    static let shared = AppIntentRouter()
    var handoff: IntentHandoff?
    private init() {}
}

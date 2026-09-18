import AppIntents
import Foundation

enum HelpCategoryIntentValue: String, AppEnum {
    case all
    case volunteer
    case events
    case donations

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Help category"

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .all: "All opportunities",
        .volunteer: "Volunteer opportunities",
        .events: "Community events",
        .donations: "Donation drives",
    ]

    var noticeKind: NoticeKind? {
        switch self {
        case .all: nil
        case .volunteer: .volunteer
        case .events: .event
        case .donations: .donation
        }
    }
}

enum NoticeKindIntentValue: String, AppEnum {
    case volunteer
    case event
    case donation

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Notice type"

    static let caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .volunteer: "Volunteer",
        .event: "Event",
        .donation: "Donation",
    ]

    var noticeKind: NoticeKind {
        switch self {
        case .volunteer: .volunteer
        case .event: .event
        case .donation: .donation
        }
    }
}

struct OpportunityEntity: AppEntity, Identifiable, Sendable {
    let id: String
    let title: String
    let organization: String
    let kind: String
    let location: String

    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Community opportunity"
    static let defaultQuery = OpportunityQuery()

    init(notice: CommunityNotice) {
        id = notice.id.uuidString
        title = notice.title
        organization = notice.organization
        kind = notice.kind.rawValue
        location = notice.location
    }

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(title)",
            subtitle: "\(organization) · \(location)",
            image: .init(systemName: "hands.sparkles.fill")
        )
    }
}

struct OpportunityQuery: EntityQuery {
    func entities(for identifiers: [OpportunityEntity.ID]) async throws -> [OpportunityEntity] {
        NoticeArchive.loadNotices()
            .filter { identifiers.contains($0.id.uuidString) }
            .map(OpportunityEntity.init)
    }

    func suggestedEntities() async throws -> [OpportunityEntity] {
        NoticeArchive.loadNotices()
            .sorted { $0.date < $1.date }
            .prefix(8)
            .map(OpportunityEntity.init)
    }
}

struct OpenHelpCategoryIntent: AppIntent {
    static let title: LocalizedStringResource = "Find ways to help"
    static let description = IntentDescription("Open Help Nah Man to a selected type of community opportunity.")
    static let openAppWhenRun = true

    @Parameter(title: "Category", default: .all)
    var category: HelpCategoryIntentValue

    static var parameterSummary: some ParameterSummary {
        Summary("Find \(\.$category)")
    }

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AppIntentRouter.shared.handoff = IntentHandoff(action: .openCategory(category.noticeKind))
        }
        return .result()
    }
}

struct OpenNoticeComposerIntent: AppIntent {
    static let title: LocalizedStringResource = "Post a community notice"
    static let description = IntentDescription("Open Help Nah Man to post a volunteer opportunity, event or donation drive.")
    static let openAppWhenRun = true

    @Parameter(title: "Notice type", default: .volunteer)
    var kind: NoticeKindIntentValue

    static var parameterSummary: some ParameterSummary {
        Summary("Post a \(\.$kind) notice")
    }

    func perform() async throws -> some IntentResult {
        await MainActor.run {
            AppIntentRouter.shared.handoff = IntentHandoff(action: .compose(kind.noticeKind))
        }
        return .result()
    }
}

struct SupportOpportunityIntent: AppIntent {
    static let title: LocalizedStringResource = "Support an opportunity"
    static let description = IntentDescription("Register your interest in a Help Nah Man community opportunity without opening the app.")
    static let openAppWhenRun = false

    @Parameter(title: "Opportunity")
    var opportunity: OpportunityEntity

    static var parameterSummary: some ParameterSummary {
        Summary("Support \(\.$opportunity)")
    }

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard
            let id = UUID(uuidString: opportunity.id),
            let notice = NoticeArchive.pledge(to: id)
        else {
            return .result(dialog: "This opportunity has reached its goal or is no longer available.")
        }

        return .result(dialog: "Your hand is up for \(notice.title). Open Help Nah Man for the organizer's contact details.")
    }
}

struct HelpNahManShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenHelpCategoryIntent(),
            phrases: [
                "Find \(\.$category) help with \(.applicationName)",
                "Show ways to help in \(.applicationName)",
            ],
            shortTitle: "Find ways to help",
            systemImageName: "hands.sparkles.fill"
        )

        AppShortcut(
            intent: OpenNoticeComposerIntent(),
            phrases: [
                "Post a notice in \(.applicationName)",
                "Share a community need with \(.applicationName)",
            ],
            shortTitle: "Post a notice",
            systemImageName: "square.and.pencil"
        )

        AppShortcut(
            intent: SupportOpportunityIntent(),
            phrases: [
                "Support \(\.$opportunity) with \(.applicationName)",
            ],
            shortTitle: "Support an opportunity",
            systemImageName: "heart.circle.fill"
        )
    }
}

import Foundation

enum NoticeKind: String, Codable, CaseIterable, Identifiable, Hashable, Sendable {
    case volunteer = "Volunteer"
    case event = "Event"
    case donation = "Donation"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .volunteer: "hands.sparkles.fill"
        case .event: "calendar.badge.clock"
        case .donation: "gift.fill"
        }
    }

    var actionTitle: String {
        switch self {
        case .volunteer: "I want to help"
        case .event: "I want to attend"
        case .donation: "Make a contribution"
        }
    }
}

struct CommunityNotice: Codable, Identifiable, Hashable, Sendable {
    let id: UUID
    var kind: NoticeKind
    var title: String
    var organization: String
    var cause: String
    var date: Date
    var location: String
    var details: String
    var contact: String
    var goal: Int
    var pledged: Int
    var isFeatured: Bool
    var createdAt: Date

    var remaining: Int { max(goal - pledged, 0) }
    var progress: Double { goal == 0 ? 0 : min(Double(pledged) / Double(goal), 1) }

    static let samples: [CommunityNotice] = {
        let calendar = Calendar.current
        let now = Date()

        func date(days: Int, hour: Int) -> Date {
            let shifted = calendar.date(byAdding: .day, value: days, to: now) ?? now
            return calendar.date(bySettingHour: hour, minute: 0, second: 0, of: shifted) ?? shifted
        }

        return [
            CommunityNotice(
                id: UUID(uuidString: "F8E17BC0-E43F-46D8-B247-45840636A101")!,
                kind: .volunteer,
                title: "Pack 300 food hampers for families across South Trinidad",
                organization: "The Gathering Place",
                cause: "Food support",
                date: date(days: 3, hour: 9),
                location: "Coffee Street, San Fernando",
                details: "Help sort pantry items and pack family hampers for distribution. Comfortable shoes and plenty good energy are all you need.",
                contact: "hello@thegatheringplace.tt",
                goal: 40,
                pledged: 26,
                isFeatured: true,
                createdAt: date(days: -1, hour: 12)
            ),
            CommunityNotice(
                id: UUID(uuidString: "F8E17BC0-E43F-46D8-B247-45840636A102")!,
                kind: .donation,
                title: "Back-to-school drive needs books, bags and stationery",
                organization: "Bright Futures TT",
                cause: "Education",
                date: date(days: 6, hour: 10),
                location: "Chaguanas Borough Corporation",
                details: "New and gently used school supplies will support primary school children ahead of the new term. Drop-offs are welcome all week.",
                contact: "donate@brightfuturestt.org",
                goal: 150,
                pledged: 82,
                isFeatured: false,
                createdAt: date(days: -2, hour: 9)
            ),
            CommunityNotice(
                id: UUID(uuidString: "F8E17BC0-E43F-46D8-B247-45840636A103")!,
                kind: .event,
                title: "Free health checks and family wellness day",
                organization: "Healthy Hearts Caribbean",
                cause: "Health",
                date: date(days: 8, hour: 8),
                location: "Queen's Park Savannah, Port of Spain",
                details: "Come for blood pressure and glucose screening, talks with local nurses, movement sessions and activities for the whole family.",
                contact: "868-555-0142",
                goal: 250,
                pledged: 104,
                isFeatured: false,
                createdAt: date(days: -3, hour: 14)
            ),
            CommunityNotice(
                id: UUID(uuidString: "F8E17BC0-E43F-46D8-B247-45840636A104")!,
                kind: .volunteer,
                title: "Maracas shoreline clean-up and recycling sort",
                organization: "Clean Coast Collective",
                cause: "Environment",
                date: date(days: 10, hour: 6),
                location: "Maracas Bay",
                details: "Join an early-morning beach clean-up, then help separate and record what we collect. Gloves, bags and water will be provided.",
                contact: "join@cleancoast.co.tt",
                goal: 80,
                pledged: 53,
                isFeatured: false,
                createdAt: date(days: -4, hour: 11)
            ),
            CommunityNotice(
                id: UUID(uuidString: "F8E17BC0-E43F-46D8-B247-45840636A105")!,
                kind: .donation,
                title: "Help restock the Arima animal shelter pantry",
                organization: "Paws & Care Network",
                cause: "Animals",
                date: date(days: 13, hour: 9),
                location: "Calvary Road, Arima",
                details: "The shelter needs dry food, cleaning supplies and washable blankets. Every contribution keeps rescued animals safe and comfortable.",
                contact: "pawsandcarett@gmail.com",
                goal: 100,
                pledged: 31,
                isFeatured: false,
                createdAt: date(days: -5, hour: 16)
            ),
        ]
    }()
}

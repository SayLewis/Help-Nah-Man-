import SwiftUI

struct BrandMark: View {
    @Environment(AppTheme.self) private var theme

    var body: some View {
        Text("H!")
            .font(.system(.headline, design: .serif, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 42, height: 42)
            .background(theme.coral, in: UnevenRoundedRectangle(cornerRadii: .init(topLeading: 21, bottomLeading: 7, bottomTrailing: 21, topTrailing: 21)))
            .rotationEffect(.degrees(-5))
            .accessibilityHidden(true)
    }
}

struct KindPill: View {
    @Environment(AppTheme.self) private var theme
    let kind: NoticeKind

    var body: some View {
        Label(kind.rawValue, systemImage: kind.systemImage)
            .font(.caption.weight(.bold))
            .textCase(.uppercase)
            .foregroundStyle(kind == .event ? theme.ink : .white)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(theme.kindColor(kind), in: Capsule())
    }
}

struct NoticeCard: View {
    @Environment(AppTheme.self) private var theme

    let notice: CommunityNotice
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top) {
                    KindPill(kind: notice.kind)
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0) {
                        Text(notice.date, format: .dateTime.month(.abbreviated))
                            .font(.caption2.weight(.heavy))
                            .textCase(.uppercase)
                            .foregroundStyle(theme.coral)
                        Text(notice.date, format: .dateTime.day())
                            .font(.system(.title, design: .serif, weight: .bold))
                            .foregroundStyle(theme.forest)
                    }
                }

                Text(notice.title)
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundStyle(theme.ink)
                    .multilineTextAlignment(.leading)

                Text("By \(notice.organization)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(theme.forestSoft)

                Label(notice.location, systemImage: "mappin.and.ellipse")
                    .font(.caption)
                    .foregroundStyle(theme.muted)
                    .lineLimit(2)

                VStack(alignment: .leading, spacing: 7) {
                    ProgressView(value: notice.progress)
                        .tint(theme.coral)
                    Text("\(notice.remaining) still needed")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(theme.muted)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.cream, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(theme.ink.opacity(0.09), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(notice.kind.rawValue): \(notice.title), by \(notice.organization), \(notice.date.formatted(date: .abbreviated, time: .shortened)), at \(notice.location), \(notice.remaining) still needed")
    }
}

struct EmptyStateView: View {
    @Environment(AppTheme.self) private var theme
    let icon: String
    let title: String
    let message: String

    var body: some View {
        ContentUnavailableView {
            Label(title, systemImage: icon)
                .foregroundStyle(theme.forest)
        } description: {
            Text(message)
                .foregroundStyle(theme.muted)
        }
    }
}

struct PostToolbarButton: ToolbarContent {
    @Environment(AppRouter.self) private var router

    var body: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Button {
                router.sheet = .composer(nil)
            } label: {
                Label("Post a notice", systemImage: "plus")
            }
            .accessibilityHint("Opens the community notice form")
        }
    }
}

extension View {
    func helpNahManDestinations() -> some View {
        navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .notice(let id): NoticeDetailView(noticeID: id)
            }
        }
    }
}

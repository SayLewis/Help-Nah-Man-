import Foundation
import SwiftUI

struct NoticeDetailView: View {
    @Environment(NoticeStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(AppTheme.self) private var theme

    let noticeID: UUID

    var body: some View {
        Group {
            if let notice = store.notice(id: noticeID) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        header(for: notice)
                        details(for: notice)
                        progress(for: notice)
                        safetyNote
                    }
                    .padding(18)
                    .padding(.bottom, 100)
                    .frame(maxWidth: 680, alignment: .leading)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
                .safeAreaInset(edge: .bottom) {
                    actionBar(for: notice)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            store.toggleSaved(notice.id)
                        } label: {
                            Image(systemName: store.savedIDs.contains(notice.id) ? "bookmark.fill" : "bookmark")
                        }
                        .accessibilityLabel(store.savedIDs.contains(notice.id) ? "Remove bookmark" : "Save opportunity")
                    }
                }
            } else {
                EmptyStateView(icon: "exclamationmark.triangle", title: "Notice unavailable", message: "This community notice may have been removed.")
            }
        }
        .background(theme.paper)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func header(for notice: CommunityNotice) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            KindPill(kind: notice.kind)
            Text(notice.title)
                .font(.system(.largeTitle, design: .serif, weight: .bold))
                .foregroundStyle(theme.ink)
            Text("By \(notice.organization)")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(theme.forestSoft)
        }
    }

    private func details(for notice: CommunityNotice) -> some View {
        VStack(alignment: .leading, spacing: 18) {
            detailRow(icon: "calendar", title: "When", value: notice.date.formatted(date: .abbreviated, time: .shortened))
            Link(destination: mapsURL(for: notice.location)) {
                detailRow(icon: "mappin.and.ellipse", title: "Where", value: notice.location)
            }
            .accessibilityHint("Opens Maps")
            detailRow(icon: "heart.text.square", title: "Cause", value: notice.cause)

            Divider()
            Text("What’s happening")
                .font(.system(.title2, design: .serif, weight: .bold))
            Text(notice.details)
                .font(.body)
                .foregroundStyle(theme.muted)
                .lineSpacing(5)
        }
        .padding(20)
        .background(theme.cream, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 13) {
            Image(systemName: icon)
                .foregroundStyle(theme.coral)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 3) {
                Text(title.uppercased())
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(theme.muted)
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.ink)
            }
        }
    }

    private func progress(for notice: CommunityNotice) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .lastTextBaseline) {
                Text("Community response")
                    .font(.system(.title2, design: .serif, weight: .bold))
                Spacer()
                Text("\(notice.pledged) of \(notice.goal)")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(theme.muted)
            }
            ProgressView(value: notice.progress)
                .tint(theme.coral)
            Text("\(notice.remaining) more \(notice.kind == .event ? "attendees" : "contributions") needed to reach the goal.")
                .font(.caption)
                .foregroundStyle(theme.muted)
        }
    }

    private var safetyNote: some View {
        Label {
            Text("Confirm the details with the listed organization before attending or donating.")
        } icon: {
            Image(systemName: "checkmark.shield.fill")
                .foregroundStyle(theme.forest)
        }
        .font(.caption)
        .foregroundStyle(theme.muted)
        .padding(16)
        .background(theme.mint, in: RoundedRectangle(cornerRadius: 14))
    }

    private func actionBar(for notice: CommunityNotice) -> some View {
        Button {
            router.sheet = .participation(notice.id)
        } label: {
            Text(notice.remaining == 0 ? "Goal reached" : notice.kind.actionTitle)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.white)
        .background(theme.coral, in: RoundedRectangle(cornerRadius: 14))
        .disabled(notice.remaining == 0)
        .opacity(notice.remaining == 0 ? 0.55 : 1)
        .padding(.horizontal, 18)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
    }
}

struct ParticipationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NoticeStore.self) private var store
    @Environment(AppTheme.self) private var theme
    let noticeID: UUID

    var body: some View {
        NavigationStack {
            Group {
                if let notice = store.notice(id: noticeID) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 22) {
                            KindPill(kind: notice.kind)
                            Text("Ready to show up?")
                                .font(.system(.largeTitle, design: .serif, weight: .bold))
                            Text(notice.title)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(theme.muted)
                            if let url = contactURL(for: notice.contact) {
                                Link(destination: url) {
                                    organizerContact(notice.contact)
                                }
                                .accessibilityHint("Contacts the organizer")
                            } else {
                                organizerContact(notice.contact)
                            }
                            Text("We’ll record your interest on this device only. Contact the organizer above to confirm arrangements.")
                                .font(.footnote)
                                .foregroundStyle(theme.muted)
                            Button {
                                store.pledge(to: notice.id)
                                dismiss()
                            } label: {
                                Text(notice.kind.actionTitle)
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 15)
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.white)
                            .background(theme.coral, in: RoundedRectangle(cornerRadius: 14))
                        }
                        .padding(20)
                    }
                    .background(theme.paper)
                } else {
                    EmptyStateView(icon: "exclamationmark.triangle", title: "Notice unavailable", message: "Please choose another opportunity.")
                }
            }
            .navigationTitle("Take part")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func organizerContact(_ contact: String) -> some View {
        Label(contact, systemImage: "person.crop.circle.badge.checkmark")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(theme.forest)
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(theme.mint, in: RoundedRectangle(cornerRadius: 14))
    }
}

private func mapsURL(for location: String) -> URL {
    var components = URLComponents()
    components.scheme = "https"
    components.host = "maps.apple.com"
    components.queryItems = [URLQueryItem(name: "q", value: location)]
    return components.url!
}

private func contactURL(for contact: String) -> URL? {
    let value = contact.trimmingCharacters(in: .whitespacesAndNewlines)
    if let url = URL(string: value), url.scheme != nil {
        return url
    }
    if value.contains("@") {
        return URL(string: "mailto:\(value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? value)")
    }
    let phone = value.filter { $0.isNumber || $0 == "+" }
    return phone.count >= 7 ? URL(string: "tel:\(phone)") : nil
}

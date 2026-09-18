import SwiftUI

struct DiscoverView: View {
    @Environment(NoticeStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(AppTheme.self) private var theme
    @State private var query = ""

    private var filteredNotices: [CommunityNotice] {
        store.notices.filter { notice in
            let matchesKind = router.discoverFilter == nil || notice.kind == router.discoverFilter
            let text = [notice.title, notice.organization, notice.cause, notice.location, notice.details]
                .joined(separator: " ")
                .lowercased()
            return matchesKind && (query.isEmpty || text.contains(query.lowercased()))
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            categoryFilters

            if filteredNotices.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No matching notices",
                    message: "Try a different search or choose another category."
                )
            } else {
                List(filteredNotices) { notice in
                    NoticeCard(notice: notice) {
                        router.show(notice.id, in: .discover)
                    }
                    .listRowInsets(.init(top: 7, leading: 18, bottom: 7, trailing: 18))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
        .background(theme.paper)
        .navigationTitle("Discover")
        .searchable(text: $query, placement: .navigationBarDrawer(displayMode: .always), prompt: "Cause, place or organization")
    }

    private var categoryFilters: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 8) {
                filterButton(title: "All", icon: "square.grid.2x2.fill", kind: nil)
                ForEach(NoticeKind.allCases) { kind in
                    filterButton(title: kind.rawValue, icon: kind.systemImage, kind: kind)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
        }
        .background(theme.paper)
    }

    private func filterButton(title: String, icon: String, kind: NoticeKind?) -> some View {
        let isSelected = router.discoverFilter == kind
        return Button {
            router.discoverFilter = kind
        } label: {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? Color.white : theme.ink)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .frame(minHeight: 44)
                .background(isSelected ? theme.forest : theme.cream, in: Capsule())
                .overlay(Capsule().stroke(theme.ink.opacity(isSelected ? 0 : 0.1)))
        }
        .buttonStyle(.plain)
    }
}

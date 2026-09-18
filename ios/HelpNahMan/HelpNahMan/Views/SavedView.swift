import SwiftUI

struct SavedView: View {
    @Environment(NoticeStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(AppTheme.self) private var theme

    var body: some View {
        Group {
            if store.savedNotices.isEmpty {
                EmptyStateView(
                    icon: "bookmark",
                    title: "Nothing saved yet",
                    message: "Bookmark opportunities you want to revisit and they will appear here."
                )
            } else {
                List(store.savedNotices) { notice in
                    NoticeCard(notice: notice) {
                        router.show(notice.id, in: .saved)
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
        .navigationTitle("Saved")
    }
}

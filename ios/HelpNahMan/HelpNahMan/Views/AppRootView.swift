import SwiftUI

struct AppRootView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppIntentRouter.self) private var intentRouter
    @Environment(AppTheme.self) private var theme

    var body: some View {
        @Bindable var router = router

        TabView(selection: $router.selectedTab) {
            NavigationStack(path: $router.homePath) {
                HomeView()
                    .helpNahManDestinations()
                    .toolbar { PostToolbarButton() }
            }
            .tabItem { Label(AppTab.home.title, systemImage: AppTab.home.systemImage) }
            .tag(AppTab.home)

            NavigationStack(path: $router.discoverPath) {
                DiscoverView()
                    .helpNahManDestinations()
                    .toolbar { PostToolbarButton() }
            }
            .tabItem { Label(AppTab.discover.title, systemImage: AppTab.discover.systemImage) }
            .tag(AppTab.discover)

            NavigationStack(path: $router.savedPath) {
                SavedView()
                    .helpNahManDestinations()
                    .toolbar { PostToolbarButton() }
            }
            .tabItem { Label(AppTab.saved.title, systemImage: AppTab.saved.systemImage) }
            .tag(AppTab.saved)

            NavigationStack(path: $router.aboutPath) {
                AboutView()
                    .toolbar { PostToolbarButton() }
            }
            .tabItem { Label(AppTab.about.title, systemImage: AppTab.about.systemImage) }
            .tag(AppTab.about)
        }
        .background(theme.paper)
        .sheet(item: $router.sheet) { destination in
            switch destination {
            case .composer(let kind):
                PostNoticeView(prefilledKind: kind)
            case .participation(let noticeID):
                ParticipationView(noticeID: noticeID)
            }
        }
        .onOpenURL { url in
            _ = router.handle(url: url)
        }
        .onChange(of: intentRouter.handoff, initial: true) { _, handoff in
            guard let handoff else { return }
            router.handle(handoff.action)
            intentRouter.handoff = nil
        }
    }
}

#Preview("Community feed") {
    AppRootView()
        .environment(NoticeStore.preview)
        .environment(AppRouter())
        .environment(AppTheme())
        .environment(AppIntentRouter.shared)
}

#Preview("Empty app") {
    AppRootView()
        .environment(NoticeStore.emptyPreview)
        .environment(AppRouter())
        .environment(AppTheme())
        .environment(AppIntentRouter.shared)
}

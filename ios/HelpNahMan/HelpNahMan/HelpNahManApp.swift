import SwiftUI

@main
struct HelpNahManApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @State private var store = NoticeStore()
    @State private var router = AppRouter()
    @State private var theme = AppTheme()
    @State private var intentRouter = AppIntentRouter.shared

    init() {
        HelpNahManShortcuts.updateAppShortcutParameters()
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(store)
                .environment(router)
                .environment(theme)
                .environment(intentRouter)
                .tint(theme.coral)
                .onChange(of: scenePhase) { _, phase in
                    if phase == .active { store.reload() }
                }
        }
    }
}

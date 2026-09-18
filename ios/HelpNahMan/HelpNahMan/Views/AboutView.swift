import SwiftUI

struct AboutView: View {
    @Environment(AppRouter.self) private var router
    @Environment(AppTheme.self) private var theme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HStack(spacing: 14) {
                    BrandMark()
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Help Nah Man")
                            .font(.system(.title, design: .serif, weight: .bold))
                        Text("For we, by we.")
                            .foregroundStyle(theme.muted)
                    }
                }

                Text("A community-powered noticeboard for Trinidad & Tobago.")
                    .font(.system(size: 39, weight: .bold, design: .serif))
                    .foregroundStyle(theme.forest)

                Text("We make it easier to discover real ways to volunteer, attend and give — without having to search through scattered posts and group chats.")
                    .font(.title3)
                    .foregroundStyle(theme.muted)
                    .lineSpacing(5)

                VStack(alignment: .leading, spacing: 18) {
                    value(icon: "hands.sparkles.fill", title: "Give time", copy: "Join a volunteer team and lend your skills.")
                    value(icon: "calendar.badge.clock", title: "Give support", copy: "Attend an event that strengthens your community.")
                    value(icon: "gift.fill", title: "Give resources", copy: "Contribute supplies or funds where they are needed.")
                }
                .padding(20)
                .background(theme.cream, in: RoundedRectangle(cornerRadius: 20))

                VStack(alignment: .leading, spacing: 12) {
                    Label("Stay safe", systemImage: "checkmark.shield.fill")
                        .font(.system(.title2, design: .serif, weight: .bold))
                        .foregroundStyle(theme.forest)
                    Text("Help Nah Man is a community noticeboard. Confirm dates, locations and donation instructions directly with the listed organization before taking part.")
                        .font(.subheadline)
                        .foregroundStyle(theme.muted)
                }
                .padding(20)
                .background(theme.mint, in: RoundedRectangle(cornerRadius: 20))

                Button {
                    router.sheet = .composer(nil)
                } label: {
                    Label("Post a community notice", systemImage: "square.and.pencil")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.white)
                .background(theme.coral, in: RoundedRectangle(cornerRadius: 14))

                Link(destination: URL(string: "https://help-nah-man.luischeese.chatgpt.site")!) {
                    Label("Visit the Help Nah Man website", systemImage: "safari")
                        .font(.subheadline.weight(.semibold))
                }
            }
            .padding(20)
            .padding(.bottom, 28)
        }
        .background(theme.paper)
        .navigationTitle("About")
    }

    private func value(icon: String, title: String, copy: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(theme.coral)
                .frame(width: 26)
            VStack(alignment: .leading, spacing: 3) {
                Text(title).font(.headline)
                Text(copy).font(.subheadline).foregroundStyle(theme.muted)
            }
        }
    }
}

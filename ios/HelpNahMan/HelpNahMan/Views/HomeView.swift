import SwiftUI

struct HomeView: View {
    @Environment(NoticeStore.self) private var store
    @Environment(AppRouter.self) private var router
    @Environment(AppTheme.self) private var theme

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 26) {
                masthead
                hero
                impactStrip
                categoryRow
                latestSection
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 36)
        }
        .background(theme.paper)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(theme.cream, for: .navigationBar)
    }

    private var masthead: some View {
        HStack(spacing: 12) {
            BrandMark()
            VStack(alignment: .leading, spacing: 2) {
                Text("Help Nah Man")
                    .font(.system(.title3, design: .serif, weight: .bold))
                    .foregroundStyle(theme.ink)
                Text("COMMUNITY HELP STARTS HERE")
                    .font(.caption2.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(theme.muted)
            }
        }
        .padding(.top, 12)
    }

    @ViewBuilder
    private var hero: some View {
        if let featured = store.featured {
            Button {
                router.show(featured.id, in: .home)
            } label: {
                ZStack(alignment: .bottomLeading) {
                    theme.forest
                    Circle()
                        .fill(theme.gold)
                        .frame(width: 230, height: 230)
                        .offset(x: 170, y: -120)
                    Circle()
                        .stroke(theme.coral, lineWidth: 38)
                        .frame(width: 170, height: 170)
                        .offset(x: 115, y: -25)

                    VStack(alignment: .leading, spacing: 14) {
                        Text("FEATURED NEED")
                            .font(.caption2.weight(.heavy))
                            .tracking(1.1)
                            .foregroundStyle(theme.forest)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                            .background(theme.cream)

                        Spacer(minLength: 110)

                        Text("See who needs a hand. Then lend yours.")
                            .font(.system(.largeTitle, design: .serif, weight: .bold))
                            .foregroundStyle(.white)
                            .multilineTextAlignment(.leading)

                        Text(featured.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.white.opacity(0.78))
                            .multilineTextAlignment(.leading)

                        Label("View this opportunity", systemImage: "arrow.right")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(theme.forest)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 11)
                            .background(theme.cream, in: RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(24)
                }
                .frame(minHeight: 430)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var impactStrip: some View {
        HStack(spacing: 0) {
            impactValue("\(store.notices.count)", label: "active\nnotices")
            Divider().frame(height: 44)
            impactValue("\(store.notices.reduce(0) { $0 + $1.remaining })", label: "people still\nneeded")
            Divider().frame(height: 44)
            impactValue("3", label: "ways to\nshow up")
        }
        .padding(.vertical, 15)
        .background(theme.cream, in: RoundedRectangle(cornerRadius: 16))
    }

    private func impactValue(_ value: String, label: String) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(.title2, design: .serif, weight: .bold))
                .foregroundStyle(theme.forest)
            Text(label)
                .font(.caption2)
                .foregroundStyle(theme.muted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var categoryRow: some View {
        VStack(alignment: .leading, spacing: 13) {
            Text("HOW DO YOU WANT TO HELP?")
                .font(.caption.weight(.bold))
                .tracking(1)
                .foregroundStyle(theme.coral)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 10) {
                    ForEach(NoticeKind.allCases) { kind in
                        Button {
                            router.openDiscover(kind: kind)
                        } label: {
                            Label(kind.rawValue, systemImage: kind.systemImage)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(theme.ink)
                                .padding(.horizontal, 15)
                                .padding(.vertical, 12)
                                .background(theme.cream, in: Capsule())
                                .overlay(Capsule().stroke(theme.ink.opacity(0.1)))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var latestSection: some View {
        if store.notices.isEmpty {
            EmptyStateView(icon: "newspaper", title: "No notices yet", message: "Be the first to post a community need.")
                .frame(minHeight: 260)
        } else {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .lastTextBaseline) {
                    Text("Latest from the community")
                        .font(.system(.title, design: .serif, weight: .bold))
                        .foregroundStyle(theme.ink)
                    Spacer()
                    Button("See all") { router.openDiscover(kind: nil) }
                        .font(.caption.weight(.bold))
                }

                ForEach(store.notices.prefix(3)) { notice in
                    NoticeCard(notice: notice) {
                        router.show(notice.id, in: .home)
                    }
                }
            }
        }
    }
}

import Foundation
import Observation

enum NoticeArchive {
    private static let noticesKey = "help-nah-man.ios.notices.v1"
    private static let savedKey = "help-nah-man.ios.saved.v1"

    static func loadNotices() -> [CommunityNotice] {
        guard
            let data = UserDefaults.standard.data(forKey: noticesKey),
            let notices = try? JSONDecoder().decode([CommunityNotice].self, from: data),
            !notices.isEmpty
        else { return CommunityNotice.samples }
        return notices
    }

    static func save(_ notices: [CommunityNotice]) {
        guard let data = try? JSONEncoder().encode(notices) else { return }
        UserDefaults.standard.set(data, forKey: noticesKey)
    }

    static func loadSavedIDs() -> Set<UUID> {
        let values = UserDefaults.standard.stringArray(forKey: savedKey) ?? []
        return Set(values.compactMap(UUID.init(uuidString:)))
    }

    static func saveSavedIDs(_ ids: Set<UUID>) {
        UserDefaults.standard.set(ids.map(\.uuidString), forKey: savedKey)
    }

    @discardableResult
    static func pledge(to id: UUID) -> CommunityNotice? {
        var notices = loadNotices()
        guard let index = notices.firstIndex(where: { $0.id == id }), notices[index].remaining > 0 else { return nil }
        notices[index].pledged += 1
        save(notices)
        return notices[index]
    }
}

@MainActor
@Observable
final class NoticeStore {
    private(set) var notices: [CommunityNotice]
    private(set) var savedIDs: Set<UUID>

    init(
        notices: [CommunityNotice] = NoticeArchive.loadNotices(),
        savedIDs: Set<UUID> = NoticeArchive.loadSavedIDs()
    ) {
        self.notices = notices.sorted { $0.date < $1.date }
        self.savedIDs = savedIDs
    }

    var featured: CommunityNotice? {
        notices.first(where: \.isFeatured) ?? notices.first
    }

    var savedNotices: [CommunityNotice] {
        notices.filter { savedIDs.contains($0.id) }
    }

    func notice(id: UUID) -> CommunityNotice? {
        notices.first { $0.id == id }
    }

    func add(_ notice: CommunityNotice) {
        notices.append(notice)
        notices.sort { $0.date < $1.date }
        NoticeArchive.save(notices)
    }

    func toggleSaved(_ id: UUID) {
        if savedIDs.contains(id) { savedIDs.remove(id) } else { savedIDs.insert(id) }
        NoticeArchive.saveSavedIDs(savedIDs)
    }

    func pledge(to id: UUID) {
        guard let index = notices.firstIndex(where: { $0.id == id }), notices[index].remaining > 0 else { return }
        notices[index].pledged += 1
        NoticeArchive.save(notices)
    }

    func reload() {
        notices = NoticeArchive.loadNotices().sorted { $0.date < $1.date }
        savedIDs = NoticeArchive.loadSavedIDs()
    }

    static var preview: NoticeStore {
        NoticeStore(notices: CommunityNotice.samples, savedIDs: [CommunityNotice.samples[1].id])
    }

    static var emptyPreview: NoticeStore {
        NoticeStore(notices: [], savedIDs: [])
    }
}

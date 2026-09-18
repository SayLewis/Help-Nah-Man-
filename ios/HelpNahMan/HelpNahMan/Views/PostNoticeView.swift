import SwiftUI

struct PostNoticeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(NoticeStore.self) private var store
    @Environment(AppTheme.self) private var theme

    @State private var kind: NoticeKind
    @State private var title = ""
    @State private var organization = ""
    @State private var cause = "Community care"
    @State private var date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var location = ""
    @State private var details = ""
    @State private var contact = ""
    @State private var goal = 25
    @State private var isAuthorized = false
    @FocusState private var focusedField: Field?

    private enum Field: Hashable { case title, organization, location, details, contact }

    init(prefilledKind: NoticeKind?) {
        _kind = State(initialValue: prefilledKind ?? .volunteer)
    }

    private var canPublish: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !organization.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !details.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !contact.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && isAuthorized
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Type of notice") {
                    Picker("Notice type", selection: $kind) {
                        ForEach(NoticeKind.allCases) { item in
                            Label(item.rawValue, systemImage: item.systemImage).tag(item)
                        }
                    }
                    .pickerStyle(.segmented)

                    TextField("Cause", text: $cause)
                }

                Section("The essentials") {
                    TextField("Headline", text: $title, axis: .vertical)
                        .focused($focusedField, equals: .title)
                    TextField("Organization or group", text: $organization)
                        .focused($focusedField, equals: .organization)
                    DatePicker("Date and time", selection: $date, in: Date()...)
                    TextField("Area or meeting place", text: $location)
                        .focused($focusedField, equals: .location)
                    Stepper("Goal: \(goal)", value: $goal, in: 1...10_000)
                }

                Section("Tell the community") {
                    TextField("What’s happening and what should people bring?", text: $details, axis: .vertical)
                        .lineLimit(4...8)
                        .focused($focusedField, equals: .details)
                    TextField("Contact email, phone or website", text: $contact)
                        .textInputAutocapitalization(.never)
                        .focused($focusedField, equals: .contact)
                }

                Section {
                    Toggle("I confirm these details are accurate and I am authorized to post them.", isOn: $isAuthorized)
                } footer: {
                    Text("Community members should always confirm arrangements directly with the organizer.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(theme.paper)
            .navigationTitle("Post a notice")
            .navigationBarTitleDisplayMode(.inline)
            .scrollDismissesKeyboard(.interactively)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Publish") { publish() }
                        .fontWeight(.bold)
                        .disabled(!canPublish)
                }
            }
            .onAppear { focusedField = .title }
        }
    }

    private func publish() {
        guard canPublish else { return }
        let notice = CommunityNotice(
            id: UUID(),
            kind: kind,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            organization: organization.trimmingCharacters(in: .whitespacesAndNewlines),
            cause: cause.trimmingCharacters(in: .whitespacesAndNewlines),
            date: date,
            location: location.trimmingCharacters(in: .whitespacesAndNewlines),
            details: details.trimmingCharacters(in: .whitespacesAndNewlines),
            contact: contact.trimmingCharacters(in: .whitespacesAndNewlines),
            goal: goal,
            pledged: 0,
            isFeatured: false,
            createdAt: Date()
        )
        store.add(notice)
        dismiss()
    }
}

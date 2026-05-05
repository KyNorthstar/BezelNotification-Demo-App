//
//  FakeApp.swift
//  Howl Demo App
//
//  Created by Ky directing Claude Opus 4.7 on 2026-04-29.
//

import SwiftUI
import FoundationModels


struct FakeApp: View {
    @State private var store = DigestStore()
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(store.items) { item in
                        DigestRow(item: item)
                    }
                } header: {
                    if store.isLoading {
                        ProgressView()
                    }
                    else {
                        Text("Today")
                    }
                } footer: {
//                    if store.items.isEmpty == false {
//                        Text("\(store.items.count) items, refreshed just now.")
//                    }
                }
            }
//            .navigationTitle("Daily Digest")
//            .navigationDestination(for: DigestItem.self) { item in
//                DetailView(item: item)
//            }
#if os(macOS)
            .contextMenu {
                Button("Refresh", systemImage: "arrow.clockwise") {
                    Task { await store.refresh() }
                }
            }
#endif
            .task {
                if store.items.isEmpty {
                    await store.refresh()
                }
            }
            .refreshable {
                await store.refresh()
            }
        }
    }
}


private struct DigestRow: View {
    let item: DigestItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(item.title)
                .font(.headline)
            Text(item.source)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(item.summary)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 2)
    }
}


private struct DetailView: View {
    let item: DigestItem

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.title)
                    .font(.largeTitle.bold())
                Text(item.source)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Divider()
                Text(item.summary)
                    .font(.body)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Article")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}


/// One digest entry. `@Generable` lets the on-device model populate it directly.
@Generable
struct DigestItem: Identifiable, Hashable {
    @Guide(description: "A short, neutral, plausible headline for a story.")
    var title: String

    @Guide(description: "A publication name.")
    var source: String

    @Guide(description: "A two to three sentence neutral summary.")
    var summary: String

    var id: String { title }
}


@Generable
private struct Digest {
    @Guide(description: "Several unrelated digest items.")
    var items: [DigestItem]
}


/// Owns the visible list and the loading flag.
/// Tries Foundation Models first; falls back to bundled items on unavailability or error.
@MainActor
@Observable
final class DigestStore {
    private(set) var items: [DigestItem] = []
    private(set) var isLoading = false

    func refresh() async {
        isLoading = true
        defer { isLoading = false }

        if let generated = await generate() {
            items = generated
        } else {
            items = Self.fallbackItems
        }
    }

    private func generate() async -> [DigestItem]? {
        guard case .available = SystemLanguageModel.default.availability else {
            return nil
        }

        let session = LanguageModelSession(instructions: """
            You produce filler content for a UI mockup. \
            Items should be neutral, mundane, and plausible.
            """)

        do {
            let response = try await session.respond(
                to: "Generate a daily digest of at least 7 short, unrelated items.",
                generating: Digest.self
            )
            return response.content.items
        } catch {
            return nil
        }
    }

    static let fallbackItems: [DigestItem] = [
        DigestItem(
            title: "City Council Approves Greenway Extension",
            source: "Riverside Gazette",
            summary: "Plans to extend the waterfront path by two miles passed unanimously last night. Work is expected to start next spring."
        ),
        DigestItem(
            title: "Library Lecture Series Returns",
            source: "Town Bulletin",
            summary: "The fall lecture series resumes Thursday with a talk on regional history. Sessions are free and open to the public."
        ),
        DigestItem(
            title: "Farmers Market Adds Saturday Hours",
            source: "Daily Ledger",
            summary: "Vendors voted to extend the seasonal market through October. Live music will rotate weekly."
        ),
        DigestItem(
            title: "School District Updates Bus Routes",
            source: "Education Weekly",
            summary: "Several middle school routes have been adjusted ahead of the new term. Updated schedules are posted online."
        ),
        DigestItem(
            title: "Community Center Renovation Underway",
            source: "Neighborhood Report",
            summary: "The east wing reopens in November with new meeting rooms. Programming continues in the main hall."
        ),
    ]
}



#Preview {
    FakeApp()
}

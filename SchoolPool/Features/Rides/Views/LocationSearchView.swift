import SwiftUI
import MapKit

struct LocationSearchView: View {
    let title: String
    let onSelect: (RideLocation) -> Void

    @StateObject private var search = LocationSearchModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List(search.results, id: \.self) { completion in
                Button {
                    Task {
                        if let location = await search.resolve(completion) {
                            onSelect(location)
                            dismiss()
                        }
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(completion.title)
                            .foregroundStyle(Color.spTextPrimary)
                        if !completion.subtitle.isEmpty {
                            Text(completion.subtitle)
                                .font(.caption)
                                .foregroundStyle(Color.spTextSecondary)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .searchable(text: $search.query, prompt: "Search for a place")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
        }
    }
}

@MainActor
final class LocationSearchModel: NSObject, ObservableObject {
    @Published var query = "" {
        didSet { completer.queryFragment = query }
    }
    @Published private(set) var results: [MKLocalSearchCompletion] = []

    private let completer = MKLocalSearchCompleter()

    override init() {
        super.init()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    func resolve(_ completion: MKLocalSearchCompletion) async -> RideLocation? {
        let request = MKLocalSearch.Request(completion: completion)
        guard let response = try? await MKLocalSearch(request: request).start(),
              let item = response.mapItems.first else { return nil }
        let coordinate = item.placemark.coordinate
        return RideLocation(
            title: completion.title,
            subtitle: completion.subtitle,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
    }
}

extension LocationSearchModel: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let completions = completer.results
        Task { @MainActor in
            self.results = completions
        }
    }
}

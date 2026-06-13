import Foundation

final class ChartRangeStore: ObservableObject {
    static let shared = ChartRangeStore()

    @Published var range: String {
        didSet {
            let normalized = HistoryStore.Range(rawValue: range)?.rawValue ?? HistoryStore.Range.m1.rawValue
            if normalized != range {
                range = normalized
                return
            }
            UserDefaults.standard.set(range, forKey: Self.userDefaultsKey)
        }
    }

    var resolvedRange: HistoryStore.Range {
        HistoryStore.Range(rawValue: range) ?? .m1
    }

    private static let userDefaultsKey = "chartTimeRange"

    private init() {
        let stored = UserDefaults.standard.string(forKey: Self.userDefaultsKey)
        range = HistoryStore.Range(rawValue: stored ?? "")?.rawValue ?? HistoryStore.Range.m1.rawValue
    }
}

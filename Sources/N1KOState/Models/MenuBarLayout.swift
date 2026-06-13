import Foundation

/// Rendering modes for the compact menu-bar readout.
enum MenuBarLayout: String, CaseIterable, Identifiable {
    case standard
    case compact
    case stacked
    case minimal

    var id: String { rawValue }

    var title: String {
        switch self {
        case .standard: return "Standard"
        case .compact: return "Compact"
        case .stacked: return "Stacked"
        case .minimal: return "Minimal"
        }
    }

    static func normalized(_ raw: String?, legacyCompact: Bool) -> MenuBarLayout {
        if let raw, let layout = MenuBarLayout(rawValue: raw) { return layout }
        return legacyCompact ? .compact : .standard
    }
}

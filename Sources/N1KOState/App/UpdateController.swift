import AppKit
import Sparkle

/// Thin wrapper around Sparkle so AppKit-facing code does not spread across the app.
final class UpdateController: NSObject {
    static let shared = UpdateController()

    private lazy var updaterController = SPUStandardUpdaterController(
        startingUpdater: true,
        updaterDelegate: nil,
        userDriverDelegate: nil
    )

    var canCheckForUpdates: Bool {
        updaterController.updater.canCheckForUpdates
    }

    func start() {
        _ = updaterController
    }

    @objc func checkForUpdates(_ sender: Any?) {
        updaterController.checkForUpdates(sender)
    }
}

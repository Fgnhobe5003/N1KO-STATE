import SwiftUI

/// Entry point. The menu-bar icon is an `NSStatusItem` (see `MenuBarStatusController`)
/// because SwiftUI `MenuBarExtra` often fails to show a label on recent macOS.
@main
struct N1KOStateApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        Settings {
            SettingsView(fans: appDelegate.hub.fans, hub: appDelegate.hub, initialTab: nil)
        }
    }
}

import AppKit
import SwiftUI
import UserNotifications

struct OnboardingView: View {
    @ObservedObject var hub: MonitorHub
    @ObservedObject var settings = AppSettings.shared
    @ObservedObject var fans: FanControlService
    let onFinish: () -> Void
    let onBringToFront: () -> Void

    @State private var page = 0
    @State private var launchAtLogin = LoginItem.isEnabled
    @State private var helperReadyNotice = false

    init(hub: MonitorHub, onFinish: @escaping () -> Void, onBringToFront: @escaping () -> Void) {
        self.hub = hub
        self.fans = hub.fans
        self.onFinish = onFinish
        self.onBringToFront = onBringToFront
    }

    var body: some View {
        VStack(spacing: 0) {
            Group {
                switch page {
                case 0: welcomePage
                case 1: fanAuthPage
                default: startupPage
                }
            }
            .frame(height: 300)

            HStack {
                if page > 0 {
                    Button(action: { page -= 1 }) {
                        Text(loc: "Back")
                    }
                    .buttonStyle(.bordered)
                }
                Spacer()
                if page < 2 {
                    Button(action: { page += 1 }) {
                        Text(loc: "Continue")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(settings.accent)
                } else {
                    Button(action: finish) {
                        Text(loc: "Finish Setup")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(settings.accent)
                    .keyboardShortcut(.defaultAction)
                }
            }
            .padding(20)
        }
        .frame(width: 480, height: 380)
        .onAppear {
            fans.refreshHelperStatus()
            advanceAfterHelperReadyIfNeeded()
        }
        .onChange(of: page) { _ in advanceAfterHelperReadyIfNeeded() }
        .onChange(of: fans.helperState) { _ in advanceAfterHelperReadyIfNeeded() }
    }

    private var welcomePage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc: "Welcome to N1KO-STATE")
                .font(.system(size: 20, weight: .bold))
            Text(loc: "N1KO-STATE lives in your menu bar. Left-click the icon for the monitoring panel; right-click for the menu.")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            HStack(spacing: 12) {
                Label("CPU, GPU, Memory".loc, systemImage: "cpu")
                Label("Network & Disk".loc, systemImage: "externaldrive")
                Label("Sensors & Fans".loc, systemImage: "thermometer")
            }
            .font(.system(size: 11))
            .foregroundColor(Theme.textTertiary)
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var fanAuthPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc: "Fan Control Authorization")
                .font(.system(size: 18, weight: .bold))
            Text(loc: "Manual fan control installs a small system helper. You only need to enter your administrator password once; without it, fan speeds are read-only.")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                helperStatusBadge
                Spacer()
                Button(action: { fans.warmAuthorization() }) {
                    Text(loc: "Authorize Now")
                }
                .buttonStyle(.borderedProminent)
                .tint(settings.accent)
                .disabled(fans.helperState == .installing || fans.helperState == .ready)

                Button(action: { fans.markDeclined(); page += 1 }) {
                    Text(loc: "Skip")
                }
                .buttonStyle(.bordered)
            }

            if let err = fans.lastError, fans.helperState != .ready {
                Text(err)
                    .font(.system(size: 10.5))
                    .foregroundColor(Theme.danger)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var helperStatusBadge: some View {
        switch fans.helperState {
        case .ready:
            Label("Installed".loc, systemImage: "checkmark.circle.fill")
                .foregroundColor(Theme.ok)
        case .installing:
            Label("Installing…".loc, systemImage: "arrow.clockwise")
                .foregroundColor(Theme.info)
        case .declined:
            Label("Skipped".loc, systemImage: "minus.circle")
                .foregroundColor(Theme.textTertiary)
        case .failed(let msg):
            Label(msg, systemImage: "exclamationmark.triangle")
                .foregroundColor(Theme.danger)
                .lineLimit(2)
        default:
            Label("Not installed".loc, systemImage: "circle")
                .foregroundColor(Theme.textTertiary)
        }
    }

    private var startupPage: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(loc: "Startup & Notifications")
                .font(.system(size: 18, weight: .bold))

            if helperReadyNotice {
                Label("Fan control is ready. Continue with the final step.".loc,
                      systemImage: "checkmark.circle.fill")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(Theme.ok)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if LoginItem.isAvailable {
                Toggle(isOn: Binding(
                    get: { launchAtLogin },
                    set: { launchAtLogin = $0; LoginItem.set($0) }
                )) {
                    Text(loc: "Launch at login")
                        .font(.system(size: 12.5))
                }
                .toggleStyle(.switch)
                .tint(settings.accent)
            }

            if AlertManager.notificationsSupported {
                Text(loc: "Alert notifications require permission. You will be asked when the first threshold is crossed.")
                    .font(.system(size: 11.5))
                    .foregroundColor(Theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func finish() {
        DispatchQueue.main.async {
            onFinish()
        }
    }

    private func advanceAfterHelperReadyIfNeeded() {
        guard page == 1, fans.helperState == .ready else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            guard page == 1, fans.helperState == .ready else { return }
            helperReadyNotice = true
            page = 2
            onBringToFront()
        }
    }
}

final class OnboardingWindowController: NSObject, NSWindowDelegate {
    static let shared = OnboardingWindowController()
    private var window: NSWindow?
    private var hostingController: NSHostingController<OnboardingView>?
    private var isFinishing = false

    func show(hub: MonitorHub) {
        guard window == nil else {
            bringToFront()
            return
        }

        let hosting = NSHostingController(rootView: OnboardingView(
            hub: hub,
            onFinish: { [weak self] in self?.finishAndClose() },
            onBringToFront: { [weak self] in self?.bringToFront() }
        ))
        hostingController = hosting
        let w = NSWindow(contentViewController: hosting)
        w.title = "N1KO-STATE"
        w.styleMask = [.titled, .closable]
        w.level = .floating
        w.collectionBehavior.insert(.moveToActiveSpace)
        // ARC owns the window via our strong reference; letting AppKit also
        // release it on close would over-release and crash.
        w.isReleasedWhenClosed = false
        w.delegate = self
        w.center()
        window = w
        bringToFront()
    }

    func bringToFront() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard !isFinishing else { return true }
        let alert = NSAlert()
        alert.messageText = "Close setup guide?".loc
        alert.informativeText = "Setup is not finished yet. If you close it now, it will appear again next time.".loc
        alert.addButton(withTitle: "Keep Setup Open".loc)
        alert.addButton(withTitle: "Close".loc)
        NSApp.activate(ignoringOtherApps: true)
        return alert.runModal() == .alertSecondButtonReturn
    }

    func windowWillClose(_ notification: Notification) {
        window?.delegate = nil
        window = nil
        hostingController = nil
        isFinishing = false
    }

    private func finishAndClose() {
        DispatchQueue.main.async {
            self.isFinishing = true
            UserDefaults.standard.set(true, forKey: "didShowOnboarding")
            self.window?.orderOut(nil)
            self.window?.close()
        }
    }
}

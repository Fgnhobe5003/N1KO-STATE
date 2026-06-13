import AppKit
import SwiftUI

struct LicenseView: View {
    @ObservedObject var service = LicenseService.shared
    @ObservedObject var settings = AppSettings.shared
    let onClose: () -> Void

    @State private var code = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 8) {
                Text("N1KO")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(Theme.textPrimary)
                Text("STATE")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundColor(settings.accent)
            }

            Text(loc: "Activation Required")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Theme.textPrimary)

            Text(loc: "Enter your redemption code to activate this version.")
                .font(.system(size: 12))
                .foregroundColor(Theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

            TextField("Redemption Code".loc, text: $code)
                .textFieldStyle(.roundedBorder)
                .disabled(isValidating)

            if let error = service.lastError {
                Text(error)
                    .font(.system(size: 10.5))
                    .foregroundColor(Theme.danger)
                    .fixedSize(horizontal: false, vertical: true)
            }

            HStack {
                Spacer()
                Button(action: redeem) {
                    if isValidating {
                        ProgressView().controlSize(.small)
                    } else {
                        Text(loc: "Activate")
                    }
                }
                .buttonStyle(.borderedProminent)
                .tint(settings.accent)
                .disabled(isValidating || code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(24)
        .frame(width: 420)
        .background(.ultraThinMaterial)
        .onChange(of: service.isUnlocked) { unlocked in
            if unlocked { onClose() }
        }
        .onAppear { service.refresh() }
    }

    private var isValidating: Bool {
        if case .validating = service.state { return true }
        return false
    }

    private func redeem() {
        Task { await service.redeem(code: code) }
    }
}

final class LicenseWindowController {
    static let shared = LicenseWindowController()

    private var window: NSWindow?
    private var hostingController: NSHostingController<LicenseView>?

    func showIfNeeded() {
        LicenseService.shared.refresh()
        guard !LicenseService.shared.isUnlocked else { return }
        show()
    }

    func show() {
        if let window {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let hosting = NSHostingController(rootView: LicenseView { [weak self] in
            self?.close()
        })
        let w = NSWindow(contentViewController: hosting)
        w.title = "N1KO-STATE"
        w.styleMask = [.titled]
        w.isReleasedWhenClosed = false
        w.center()
        hostingController = hosting
        window = w
        w.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func close() {
        window?.close()
        window = nil
        hostingController = nil
    }
}

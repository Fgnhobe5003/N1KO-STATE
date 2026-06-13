import AppKit
import Combine

/// Drives the menu-bar `NSStatusItem` image from live monitor readings.
///
/// Uses a fixed-length `NSStatusItem` + `NSImage` rendering (not SwiftUI
/// `MenuBarExtra`) because the latter is unreliable on macOS Tahoe.
final class MenuBarStatusController: NSObject {

    let statusItem: NSStatusItem
    private let hub: MonitorHub
    private var cancellables = Set<AnyCancellable>()

    var onClick: (() -> Void)?
    var onHoverStart: (() -> Void)?
    var onHoverEnd: (() -> Void)?

    private static let barHeight: CGFloat = 22
    private var lastRenderSignature: String?
    private var trackingArea: NSTrackingArea?

    init(hub: MonitorHub) {
        self.hub = hub
        statusItem = NSStatusBar.system.statusItem(withLength: 184)
        super.init()
    }

    func install() {
        guard let button = statusItem.button else { return }
        button.imagePosition = .imageOnly
        button.target = self
        button.action = #selector(handleClick(_:))
        button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        button.toolTip = nil
        installTrackingArea()

        redraw(force: true)
        bindRedraws()
    }

    private func bindRedraws() {
        let monitorPub = [
            hub.cpu.objectWillChange.map { _ in () }.eraseToAnyPublisher(),
            hub.gpu.objectWillChange.map { _ in () }.eraseToAnyPublisher(),
            hub.memory.objectWillChange.map { _ in () }.eraseToAnyPublisher(),
            hub.network.objectWillChange.map { _ in () }.eraseToAnyPublisher(),
            hub.battery.objectWillChange.map { _ in () }.eraseToAnyPublisher()
        ]
        Publishers.MergeMany(monitorPub)
            .throttle(for: .seconds(2), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] _ in self?.redraw() }
            .store(in: &cancellables)

        let s = AppSettings.shared
        let settingsPub = [
            s.$menuCPU.map { _ in () }.eraseToAnyPublisher(),
            s.$menuGPU.map { _ in () }.eraseToAnyPublisher(),
            s.$menuMemory.map { _ in () }.eraseToAnyPublisher(),
            s.$menuBattery.map { _ in () }.eraseToAnyPublisher(),
            s.$menuNetwork.map { _ in () }.eraseToAnyPublisher(),
            s.$menuCompact.map { _ in () }.eraseToAnyPublisher(),
            s.$menuBarLayout.map { _ in () }.eraseToAnyPublisher(),
            s.$menuBarOrder.map { _ in () }.eraseToAnyPublisher()
        ]
        Publishers.MergeMany(settingsPub)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.redraw(force: true) }
            .store(in: &cancellables)
    }

    @objc private func handleClick(_ sender: NSStatusBarButton) {
        onClick?()
    }

    @objc(mouseEntered:) func mouseEntered(_ event: NSEvent) {
        onHoverStart?()
    }

    @objc(mouseExited:) func mouseExited(_ event: NSEvent) {
        onHoverEnd?()
    }

    private func redraw(force: Bool = false) {
        let signature = renderSignature()
        if !force, signature == lastRenderSignature { return }
        lastRenderSignature = signature
        let image = buildImage()
        statusItem.button?.image = image
        statusItem.length = max(image.size.width + 4, 24)
        installTrackingArea()
        if let label = image.accessibilityDescription {
            statusItem.button?.setAccessibilityLabel(label)
        }
    }

    private func renderSignature() -> String {
        let settings = AppSettings.shared
        let memFraction = hub.memory.total > 0 ? hub.memory.used / hub.memory.total : 0
        var parts: [String] = ["l:\(settings.resolvedMenuBarLayout.rawValue)", "c:\(settings.menuCompact)"]
        parts.append(contentsOf: settings.orderedMenuBarMetrics.map(\.rawValue))
        if settings.menuCPU { parts.append("cpu:\(Int(hub.cpu.totalUsage * 100))") }
        if settings.menuGPU { parts.append("gpu:\(Int(hub.gpu.utilization * 100))") }
        if settings.menuMemory { parts.append("mem:\(Int(memFraction * 100))") }
        if settings.menuBattery, hub.battery.isPresent {
            parts.append("bat:\(Int(hub.battery.percentage * 100)):\(hub.battery.isCharging)")
        }
        if settings.menuNetwork {
            parts.append("dn:\(Formatters.rateCompact(hub.network.downloadRate))")
            parts.append("up:\(Formatters.rateCompact(hub.network.uploadRate))")
        }
        return parts.joined(separator: "|")
    }

    private func buildImage() -> NSImage {
        let settings = AppSettings.shared
        let memFraction = hub.memory.total > 0 ? hub.memory.used / hub.memory.total : 0
        var showCPU = settings.menuCPU
        var showGPU = settings.menuGPU
        let showMem = settings.menuMemory
        let showBat = settings.menuBattery
        let showNet = settings.menuNetwork
        if !showCPU && !showGPU && !showMem && !showBat && !showNet {
            showCPU = true
            showGPU = true
        }
        let input = MenuBarImageRenderer.Input(
            cpu: hub.cpu.totalUsage,
            gpu: hub.gpu.utilization,
            mem: memFraction,
            battery: hub.battery.isPresent ? hub.battery.percentage : nil,
            batteryCharging: hub.battery.isCharging,
            down: hub.network.downloadRate,
            up: hub.network.uploadRate,
            showCPU: showCPU,
            showGPU: showGPU,
            showMem: showMem,
            showBattery: showBat,
            showNet: showNet,
            metricOrder: settings.orderedMenuBarMetrics,
            height: Self.barHeight,
            layout: settings.resolvedMenuBarLayout,
            compact: settings.menuCompact
        )
        return MenuBarImageRenderer.render(input)
    }

    func isMouseOverStatusItem() -> Bool {
        guard let button = statusItem.button,
              let window = button.window else { return false }
        let windowPoint = window.convertPoint(fromScreen: NSEvent.mouseLocation)
        let point = button.convert(windowPoint, from: nil)
        return button.bounds.contains(point)
    }

    private func installTrackingArea() {
        guard let button = statusItem.button else { return }
        if let trackingArea {
            button.removeTrackingArea(trackingArea)
        }
        let area = NSTrackingArea(
            rect: .zero,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        button.addTrackingArea(area)
        trackingArea = area
    }

}

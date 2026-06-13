import AppKit
import XCTest
@testable import N1KOState

final class MenuBarStatusControllerTests: XCTestCase {

    func testTrackingAreaSelectorsUseAppKitNames() {
        let controller = MenuBarStatusController(hub: MonitorHub())
        defer { NSStatusBar.system.removeStatusItem(controller.statusItem) }

        XCTAssertTrue(controller.responds(to: NSSelectorFromString("mouseEntered:")))
        XCTAssertTrue(controller.responds(to: NSSelectorFromString("mouseExited:")))
    }
}

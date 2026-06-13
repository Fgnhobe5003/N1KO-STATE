import XCTest
@testable import N1KOState

final class HistoryStoreTests: XCTestCase {
    func testDownsampleLeavesSmallSeriesUntouched() {
        let values = [0.1, 0.2, 0.3]
        XCTAssertEqual(HistoryStore.downsampleForDisplay(values, maxSamples: 5), values)
    }

    func testDownsampleCapsDisplayPointCount() {
        let values = (0..<2880).map(Double.init)
        let sampled = HistoryStore.downsampleForDisplay(values, maxSamples: 180)
        XCTAssertEqual(sampled.count, 180)
    }

    func testDownsampleKeepsBucketPeaks() {
        let values = [1.0, 9.0, 2.0, 3.0, 8.0, 4.0]
        let sampled = HistoryStore.downsampleForDisplay(values, maxSamples: 3)
        XCTAssertEqual(sampled, [9.0, 3.0, 8.0])
    }
}

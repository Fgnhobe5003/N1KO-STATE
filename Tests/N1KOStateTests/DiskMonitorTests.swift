import XCTest
@testable import N1KOState

final class DiskMonitorTests: XCTestCase {
    func testRootVolumeIsAlwaysIncluded() {
        let traits = VolumeFilterTraits(
            mountPath: "/",
            totalCapacity: 20 * 1024 * 1024,
            isRoot: true,
            isRemovable: false,
            isEjectable: true,
            isReadOnly: true,
            mountFromName: "/dev/disk1s1",
            diskArbitrationDescription: ["Disk Image"]
        )

        XCTAssertTrue(DiskMonitor.shouldIncludeVolume(traits))
    }

    func testRemovableVolumesAreIncludedEvenWhenSmallAndEjectable() {
        let traits = VolumeFilterTraits(
            mountPath: "/Volumes/USB",
            totalCapacity: 64 * 1024 * 1024,
            isRoot: false,
            isRemovable: true,
            isEjectable: true,
            isReadOnly: true,
            mountFromName: "/dev/disk8s1",
            diskArbitrationDescription: ["USB"]
        )

        XCTAssertTrue(DiskMonitor.shouldIncludeVolume(traits))
    }

    func testDiskImageVolumesAreExcluded() {
        let traits = VolumeFilterTraits(
            mountPath: "/Volumes/N1KO-STATE",
            totalCapacity: 20 * 1024 * 1024,
            isRoot: false,
            isRemovable: false,
            isEjectable: true,
            isReadOnly: true,
            mountFromName: "/dev/disk9s1",
            diskArbitrationDescription: ["Disk Image", "Apple UDIF read-only compressed Media"]
        )

        XCTAssertFalse(DiskMonitor.shouldIncludeVolume(traits))
    }

    func testDiskImageVolumesAreExcludedEvenWhenSystemMarksThemRemovable() {
        let traits = VolumeFilterTraits(
            mountPath: "/Volumes/N1KO-STATE",
            totalCapacity: 23 * 1024 * 1024,
            isRoot: false,
            isRemovable: true,
            isEjectable: true,
            isReadOnly: true,
            mountFromName: "/dev/disk12s1",
            diskArbitrationDescription: ["Disk Image"]
        )

        XCTAssertFalse(DiskMonitor.shouldIncludeVolume(traits))
    }

    func testSmallReadOnlyEjectableNonRemovableVolumeIsExcludedAsInstallerFallback() {
        let traits = VolumeFilterTraits(
            mountPath: "/Volumes/N1KO-STATE",
            totalCapacity: 21 * 1024 * 1024,
            isRoot: false,
            isRemovable: false,
            isEjectable: true,
            isReadOnly: true,
            mountFromName: "/dev/disk10s1",
            diskArbitrationDescription: []
        )

        XCTAssertFalse(DiskMonitor.shouldIncludeVolume(traits))
    }

    func testLargeExternalVolumeIsIncluded() {
        let traits = VolumeFilterTraits(
            mountPath: "/Volumes/Backup",
            totalCapacity: 2 * 1024 * 1024 * 1024,
            isRoot: false,
            isRemovable: false,
            isEjectable: true,
            isReadOnly: false,
            mountFromName: "/dev/disk11s1",
            diskArbitrationDescription: ["USB"]
        )

        XCTAssertTrue(DiskMonitor.shouldIncludeVolume(traits))
    }

    func testMountedN1KOInstallerVolumeIsFilteredWhenPresent() throws {
        let keys: [URLResourceKey] = [.volumeNameKey, .volumeTotalCapacityKey]
        let mounted = FileManager.default.mountedVolumeURLs(
            includingResourceValuesForKeys: keys,
            options: [.skipHiddenVolumes]
        ) ?? []
        let installerMounted = mounted.contains { url in
            guard let values = try? url.resourceValues(forKeys: Set(keys)),
                  values.volumeName == "N1KO-STATE",
                  let total = values.volumeTotalCapacity else { return false }
            return total < 512 * 1024 * 1024
        }
        if !installerMounted {
            throw XCTSkip("N1KO-STATE installer DMG is not mounted.")
        }

        XCTAssertFalse(DiskMonitor.readVolumes().contains {
            $0.name == "N1KO-STATE" && $0.total < 512 * 1024 * 1024
        })
    }
}

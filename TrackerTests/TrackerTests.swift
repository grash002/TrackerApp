import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {

    func testViewController() {
        let vc = TabBarController()
        vc.overrideUserInterfaceStyle = .dark
        assertSnapshot(of: vc, as: .image)
    }
    
}

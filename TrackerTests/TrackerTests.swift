import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testViewController() throws {
        let vc = TrackersViewController()
        
        assertSnapshots(matching: vc, as: [
            .image(traits: .init(userInterfaceStyle: .dark)),
            .image(traits: .init(userInterfaceStyle: .light))
        ])
    }
    
}

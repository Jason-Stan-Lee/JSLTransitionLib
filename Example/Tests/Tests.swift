// https://github.com/Quick/Quick

import XCTest
import JSLTransitionLib

class TableOfContentsSpec: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testInitial() {
        let vc = UIViewController()
        vc.presentationTransitioningDelegateS = ViewControllerTransitionDelegate(presentedViewController: vc)
        XCTAssertTrue(!vc.isInteractivePresentToEnable, "Part 1 failed.")
    }
}

import XCTest

final class NASAUITests: XCTestCase {
    
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testFeed() throws {
        // wait for images feed screen
        let collectionViews = app.collectionViews
        let firstCell = collectionViews.children(matching: .cell).element(boundBy: 0)
        firstCell.swipeUp()
        sleep(5)
        let secondCell = collectionViews.children(matching: .cell).element(boundBy: 1)
        secondCell.tap()
        sleep(3)
        // wait for fullscreen image open
        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 5))
        // go back to the images feed screen
        sleep(3)
        app.buttons["CloseButton"].tap()
    }
}

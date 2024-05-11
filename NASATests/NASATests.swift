@testable import NASA
import XCTest

final class NASATests: XCTestCase {

    func testViewModelDidCalled() {
        // given
        let storage = OAuth2TokenStorage()
        let imagesListService = ImagesListService(builder: URLRequestBuilder(storage: storage))
        let viewModel = MainViewControllerViewModelSpy(storage: storage, imagesListService: imagesListService)
        let viewController = MainViewController(viewModel: viewModel)
        // when
        viewController.viewWillAppear(false)
        // then
        XCTAssertTrue(viewModel.isFirstLoadStarted)
    }
}

import UIKit
import Kingfisher

// MARK: - MainViewControllerViewModelProtocol
protocol MainViewControllerViewModelProtocol {
    var storage: OAuth2TokenStorageProtocol { get set }
    var imagesListService: ImagesListServiceProtocol { get }
    var alertPresenter: AlertPresenterProtocol? { get set }
    var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol? { get set }
    var photosArrayBinding: Binding<[Photo]>? { get set }
    var photosArray: [Photo] { get set }
    func endlessPhotosLoading(isFirstLoad: Bool)
    func startFetchPhotos()
    func downloadImageFor(cell: MainCollectionViewCell, at indexPath: IndexPath)
    func sizeOfCollectionViewCell(screeWidth: CGFloat) -> CGSize
}

// MARK: - MainViewControllerViewModel
final class MainViewControllerViewModel: MainViewControllerViewModelProtocol {
    
    // MARK: Properties
    var storage: OAuth2TokenStorageProtocol
    var imagesListService: ImagesListServiceProtocol
    var alertPresenter: AlertPresenterProtocol?
    var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol?
    var photosArrayBinding: Binding<[Photo]>?
    var photosArray: [Photo] = [] {
        didSet {
            photosArrayBinding?(photosArray)
        }
    }
    private let dateFormat: String = NSLocalizedString("mainViewControllerViewModel.dateFormat", comment: "")
    
    // MARK: Init
    init(
        storage: OAuth2TokenStorageProtocol,
        imagesListService: ImagesListServiceProtocol
    ) {
        self.storage = storage
        self.imagesListService = imagesListService
    }
    
    // MARK: Functions
    func endlessPhotosLoading(isFirstLoad: Bool) {
        if isFirstLoad {
            startFetchPhotos()
        } else {
            photosArray = imagesListService.photos
        }
    }
    
    func startFetchPhotos() {
        let oneDayBackTimeInterval = TimeInterval(-60 * 60 * 24)
        let currentDate: Date = Date(timeInterval: oneDayBackTimeInterval, since: Date())
        var dateToFetch: Date = currentDate
        if let loadedDate = imagesListService.photos.last?.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = dateFormat
            if let loadedDateFormatted = dateFormatter.date(from: loadedDate) {
                dateToFetch = loadedDateFormatted
            }
        }
        uiBlockingProgressHUD?.showCustom()
        imagesListService.fetchPhotosFrom(date: dateToFetch) { [weak self] result in
            guard let self = self else { return }
            self.uiBlockingProgressHUD?.dismissCustom()
            switch result {
            case .success(let photos):
                if photosArray.isEmpty {
                    photosArray = photos
                } else {
                    photosArray.append(contentsOf: photos)
                }
            case .failure:
                self.showNetworkError() {
                    self.startFetchPhotos()
                }
            }
        }
    }
    
    func downloadImageFor(cell: MainCollectionViewCell, at indexPath: IndexPath) {
        guard let url = self.photosArray[indexPath.row].url.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed)
        else { return }
        let processor = DownsamplingImageProcessor(size: CGSize(width: cell.bounds.width, height: cell.bounds.height))
        cell.cellImageView.kf.indicatorType = .activity
        cell.cellImageView.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(),
            options: [
                .processor(processor)
            ]
        ) { result in
            switch result {
            case .success(_):
                cell.cellImageView.contentMode = .scaleAspectFill
            case .failure(_):
                cell.cellImageView.image = UIImage.noImage
                cell.cellImageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    func sizeOfCollectionViewCell(screeWidth: CGFloat) -> CGSize {
        let screenWidth: CGFloat = screeWidth
        let insets: CGFloat = MainCollectionViewCellConstants.insets
        let cellsInRow: CGFloat = MainCollectionViewCellConstants.cellsInRow
        let cellWidthWithInsets: CGFloat = screenWidth - (insets * cellsInRow)
        let cellHeight: CGFloat = MainCollectionViewCellConstants.cellHeight
        let spacing: CGFloat = MainCollectionViewCellConstants.spacing
        let cellWidthComputed = cellWidthWithInsets / cellsInRow - spacing
        return CGSize(
            width: cellWidthComputed,
            height: cellHeight)
    }
    
    func showNetworkError(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: NSLocalizedString("showNetworkError.AlertModel.title", comment: ""),
                message: NSLocalizedString("showNetworkError.AlertModel.message", comment: ""),
                firstButton: NSLocalizedString("showNetworkError.AlertModel.firstButton", comment: ""),
                secondButton: NSLocalizedString("showNetworkError.AlertModel.secondButton", comment: ""),
                firstCompletion: completion,
                secondCompletion: {})
            self.alertPresenter?.show(with: model)
        }
    }
}

// MARK: - MainViewControllerViewModelSpy
final class MainViewControllerViewModelSpy: MainViewControllerViewModelProtocol {
    
    var storage: any OAuth2TokenStorageProtocol
    var imagesListService: any ImagesListServiceProtocol
    var alertPresenter: (any AlertPresenterProtocol)?
    var uiBlockingProgressHUD: (any UIBlockingProgressHUDProtocol)?
    var photosArrayBinding: Binding<[Photo]>?
    var photosArray: [Photo] = []
    var isFirstLoadStarted: Bool = false
    var isFetchPhotosStarted: Bool = false
    
    init(
        storage: any OAuth2TokenStorageProtocol,
        imagesListService: any ImagesListServiceProtocol
    ) {
        self.storage = storage
        self.imagesListService = imagesListService
    }
    
    func endlessPhotosLoading(isFirstLoad: Bool) {
        if isFirstLoad {
            self.isFirstLoadStarted = true
        } else {
            self.isFirstLoadStarted = false
        }
    }
    
    func startFetchPhotos() {
        isFetchPhotosStarted = true
    }
    
    func downloadImageFor(cell: MainCollectionViewCell, at indexPath: IndexPath) {
        
    }
    
    func sizeOfCollectionViewCell(screeWidth: CGFloat) -> CGSize {
        return CGSize(width: 100, height: 150)
    }
}


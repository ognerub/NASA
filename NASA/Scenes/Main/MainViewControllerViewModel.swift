import UIKit
import Kingfisher

final class MainViewControllerViewModel: ObservableObject {
    
    // MARK: Properties
    var photosArray: [Photo] = []
    var alertPresenter: AlertPresenterProtocol?
    var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol?
    var imagesListServiceObserver: NSObjectProtocol?
    let imagesListService = ImagesListService.shared
    let storage = OAuth2TokenStorage.shared
    
    private let dateFormat: String = "YYYY-MM-dd"
    
    // MARK: Functions
    func startFetch() {
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
            case .success:
                return
            case .failure:
                self.showNetWorkErrorForImagesListVC() {
                    self.startFetch()
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
    
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: NSLocalizedString("showNetWorkError.AlertModel.title", comment: ""),
                message: NSLocalizedString("showNetWorkError.AlertModel.message", comment: ""),
                firstButton: NSLocalizedString("showNetWorkError.AlertModel.firstButton", comment: ""),
                secondButton: NSLocalizedString("showNetWorkError.AlertModel.secondButton", comment: ""),
                firstCompletion: completion,
                secondCompletion: {})
            self.alertPresenter?.show(with: model)
        }
    }
}

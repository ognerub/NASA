//
//  MainViewControllerViewModel.swift
//  NASA
//
//  Created by Alexander Ognerubov on 10.05.2024.
//

import UIKit
import Kingfisher

final class MainViewControllerViewModel: ObservableObject {
    
    var photosArray: [Photo] = []
    var alertPresenter: AlertPresenterProtocol?
    var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol?
    var imagesListServiceObserver: NSObjectProtocol?
    let imagesListService = ImagesListService.shared
    let storage = OAuth2TokenStorage.shared
    
    private let dateFormat: String = "YYYY-MM-dd"
    
    func startFetch() {
        let currentDate: Date = Date()
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
                cell.cellView.contentMode = .scaleAspectFill
            case .failure(_):
                cell.cellImageView.image = UIImage.noImage
                cell.cellImageView.contentMode = .scaleAspectFit
            }
        }
    }
    
    func getSingleImageViewController(from indexPath: IndexPath, and visibleIndexPath: IndexPath?) -> UITableViewController {
        let url = photosArray[indexPath.row].url
        let date = photosArray[indexPath.row].date
        let title = photosArray[indexPath.row].title
        var explanation = ""
        if let string = photosArray[indexPath.row].explanation {
            explanation = string
        }
        return SingleImageViewController(
            photo: Photo(
                title: title,
                date: date,
                url: url,
                explanation: explanation
            ),
            tableHeaderView: SingleImageTableHeaderView(
                imageURLString: url,
                frame: CGRect(
                    origin: .zero,
                    size: CGSize(
                        width: .zero,
                        height: SingleImageTableHeaderView.baseHeight
                    )
                )
            ),
            currentCellIndex: visibleIndexPath ?? indexPath,
            viewModel: self
        )
    }
    
    func sizeOfCollectionViewCell(with type: CollectionViewCellSize, screeWidth: CGFloat) -> CGSize {
        let screenWidth: CGFloat = screeWidth
        let insets: CGFloat = 10
        let cellWidthWithInsets: CGFloat = screenWidth - (insets * 2)
        let cellHeight: CGFloat = 180
        switch type {
        case .main:
            return CGSize(
                width: cellWidthWithInsets,
                height: cellHeight + 20)
        case .standart:
            let spacing: CGFloat = 5
            let cellsInRow: CGFloat = 2
            let cellWidthComputed = cellWidthWithInsets / cellsInRow - spacing
            
            return CGSize(
                width: cellWidthComputed,
                height: cellHeight)
        }
    }
    
    func showNetWorkErrorForImagesListVC(completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            let model = AlertModel(
                title: "Что-то пошло не так(",
                message: "Попробовать еще раз?",
                firstButton: "Повторить",
                secondButton: "Не надо",
                firstCompletion: completion,
                secondCompletion: {})
            self.alertPresenter?.show(with: model)
        }
    }
}

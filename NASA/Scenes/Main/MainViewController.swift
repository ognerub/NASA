import UIKit
import Kingfisher

final class MainViewController: UIViewController {
    
    private let viewModel: MainViewControllerViewModel
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol?
    private let storage = OAuth2TokenStorage.shared
    
    private lazy var collectionView: UICollectionView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .blackColor
        return collectionView
    }()
    
    private let currentCellIndex: IndexPath
    
    init(currentCellIndex: IndexPath, viewModel: MainViewControllerViewModel) {
        self.viewModel = viewModel
        self.currentCellIndex = currentCellIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        alertPresenter = AlertPresenterImpl(viewController: self)
        uiBlockingProgressHUD = UIBlockingProgressHUD(viewController: self)
        if storage.token == nil {
            storage.token = NetworkConstants.standart.personalToken
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .blackColor
        configureCollectionView()
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.PhotoResultDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.viewModel.photosArray = self.imagesListService.photos
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        
        if imagesListService.photos.isEmpty {
            startFetch()
        } else {
            viewModel.photosArray = imagesListService.photos
            scrollToRow(indexPath: currentCellIndex)
        }
        
    }
}

private extension MainViewController {
    func scrollToRow(indexPath: IndexPath) {
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.cellReuseIdentifier)
    }
    
    func startFetch() {
        let currentDate: Date = Date()
        var dateToFetch: Date = currentDate
        if let loadedDate = imagesListService.photos.last?.date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-dd"
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

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let url = viewModel.photosArray[indexPath.row].url
        let date = viewModel.photosArray[indexPath.row].date
        let title = viewModel.photosArray[indexPath.row].title
        var explanation = ""
        if let string = viewModel.photosArray[indexPath.row].explanation {
            explanation = string
        }
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.minX + 15, y: visibleRect.minY + 15)
        let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
        let viewController =
        SingleImageViewController(
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
            viewModel: viewModel
        )
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let screenWidth: CGFloat = view.frame.width
        let insets: CGFloat = 10
        let cellWidthWithInsets: CGFloat = screenWidth - (insets * 2)
        let cellHeight: CGFloat = 180
        
        /// make first cell width equal to screen width and substract insets
        if indexPath.row == 0 {
            return CGSize(
                width: cellWidthWithInsets,
                height: cellHeight + 20)
        } else {
            let spacing: CGFloat = 5
            let cellsInRow: CGFloat = 2
            let cellWidthComputed = cellWidthWithInsets / cellsInRow - spacing
            
            return CGSize(
                width: cellWidthComputed,
                height: cellHeight)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

extension MainViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModel.photosArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainCollectionViewCell.cellReuseIdentifier,
            for: indexPath) as? MainCollectionViewCell
        else { return UICollectionViewCell() }
        cell.configureCell(text: viewModel.photosArray[indexPath.row].title)
        downloadImageFor(cell: cell, at: indexPath)
        setupGradientFor(cell: cell)
        return cell
    }
    
    private func setupGradientFor(cell: MainCollectionViewCell) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: cell.frame.height-30, width: view.frame.width-20, height: 30)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        cell.cellImageView.layer.addSublayer(gradientLayer)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.isLastRow(at: collectionView) {
            startFetch()
        }
    }
    
    private func downloadImageFor(cell: MainCollectionViewCell, at indexPath: IndexPath) {
        guard let url = self.viewModel.photosArray[indexPath.row].url.addingPercentEncoding(
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
    
    
}

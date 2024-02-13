import UIKit
import Kingfisher

final class MainViewController: UIViewController {
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol?
    
    private var array: [Photo] = []
    
    private lazy var collectionView: UICollectionView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .blackColor
        return collectionView
    }()
    
    override func loadView() {
        super.loadView()
        alertPresenter = AlertPresenterImpl(viewController: self)
        uiBlockingProgressHUD = UIBlockingProgressHUD(viewController: self)
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .blackColor
        configureCollectionView()
        startFetch()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.array = self.imagesListService.photos
            self.collectionView.reloadData()
            self.scrollToFirstRow()
        }
    }
    
    private func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.cellReuseIdentifier)
    }
    
    private func startFetch() {
        uiBlockingProgressHUD?.showCustom()
        imagesListService.fetchPhotos() { [weak self] result in
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth: CGFloat = view.frame.width
        let insets: CGFloat = 10
        let spacing: CGFloat = 5
        let cellsInRow: CGFloat = 2
        let cellWidth = (screenWidth - (insets * 2)) / cellsInRow - spacing
        
        return CGSize(width: cellWidth, height: 150)
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
        array.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: MainCollectionViewCell.cellReuseIdentifier,
            for: indexPath) as? MainCollectionViewCell
        else { return UICollectionViewCell() }
        cell.configureCell(text: array[indexPath.row].title)
        downloadImageFor(cell: cell, at: indexPath)
        return cell
    }
    
    private func downloadImageFor(cell: MainCollectionViewCell, at indexPath: IndexPath) {
        guard let url = self.array[indexPath.row].url.addingPercentEncoding(
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
                cell.cellImageView.image = UIImage(systemName: "nosign") ?? UIImage()
            }
            
        }
    }
    
    
}

import UIKit

// MARK: - MainViewController
final class MainViewController: UIViewController {
    
    // MARK: Properties
    private let viewModel: MainViewControllerViewModel
    private let currentCellIndex: IndexPath
    
    private lazy var collectionView: UICollectionView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .blackColor
        return collectionView
    }()
    
    // MARK: Init
    init(currentCellIndex: IndexPath, viewModel: MainViewControllerViewModel) {
        self.viewModel = viewModel
        self.currentCellIndex = currentCellIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Life cycles
    override func loadView() {
        super.loadView()
        viewModel.alertPresenter = AlertPresenterImpl(viewController: self)
        viewModel.uiBlockingProgressHUD = UIBlockingProgressHUD(viewController: self)
        if viewModel.storage.token == nil {
            viewModel.storage.token = NetworkConstants.standart.personalToken
        }
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .blackColor
        configureCollectionView()
        viewModel.imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.PhotoResultDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.viewModel.photosArray = self.viewModel.imagesListService.photos
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        if viewModel.imagesListService.photos.isEmpty {
            viewModel.startFetch()
        } else {
            viewModel.photosArray = viewModel.imagesListService.photos
            scrollToRow(indexPath: currentCellIndex)
        }
        
    }
}

// MARK: - Private functions
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
}

// MARK: - CollectionDelegateFlowLayout
extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.minX + 15, y: visibleRect.minY + 15)
        let visibleIndexPath = collectionView.indexPathForItem(at: visiblePoint)
        let viewControllerToPush = viewModel.getSingleImageViewController(from: indexPath, and: visibleIndexPath)
        navigationController?.pushViewController(viewControllerToPush, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = view.frame.width
        if indexPath.row == 0 {
            return viewModel.sizeOfCollectionViewCell(with: .main, screeWidth: screenWidth)
        } else {
            return viewModel.sizeOfCollectionViewCell(with: .standart, screeWidth: screenWidth)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
}

// MARK: - CollectionDataSource
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
        viewModel.downloadImageFor(cell: cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.isLastRow(at: collectionView) {
            viewModel.startFetch()
        }
    }
}

import UIKit

final class MainViewController: UIViewController {
    
    // MARK: Properties
    private var viewModel: MainViewControllerViewModelProtocol
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private lazy var collectionView: UICollectionView = {
        let frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        let collectionView = UICollectionView(frame: frame, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.backgroundColor = .blackColor
        return collectionView
    }()
    
    // MARK: Init
    init(viewModel: MainViewControllerViewModelProtocol) {
        self.viewModel = viewModel
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
        viewModel.photosArrayBinding = { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        let isCurrentPhotosEmpty = viewModel.imagesListService.photos.isEmpty
        viewModel.endlessPhotosLoading(isFirstLoad: isCurrentPhotosEmpty)
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
        let tag = indexPath.row + 1
        let photo = viewModel.photosArray[indexPath.row]
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: tag)
        let fullScreenImageViewController = FullScreenImageViewController(photo: photo, tag: tag)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        present(fullScreenImageViewController, animated: true)
        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = view.frame.width
        return viewModel.sizeOfCollectionViewCell(screeWidth: screenWidth)
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
        viewModel.downloadImageFor(cell: cell, at: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.isLastRow(at: collectionView) {
            viewModel.startFetchPhotos()
        }
    }
}

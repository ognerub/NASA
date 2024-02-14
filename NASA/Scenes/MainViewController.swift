import UIKit
import Kingfisher

final class MainViewController: UIViewController {
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol?
    
    private var array: [Photo] = [
        Photo(
          title : "MOCK - We Are Going",
          url : "https://images-assets.nasa.gov/video/NHQ_2019_0514_WeAreGoing/NHQ_2019_0514_WeAreGoing~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - We Go Together",
          url : "https://images-assets.nasa.gov/video/NHQ_2019_0528_We Go Together/NHQ_2019_0528_We Go Together~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - We Go as the Artemis Generation",
          url : "https://images-assets.nasa.gov/video/NHQ_2019_0719_We Go as the Artemis Generation/NHQ_2019_0719_We Go as the Artemis Generation~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - Going with the Flow",
          url : "https://images-assets.nasa.gov/image/PIA17850/PIA17850~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - Going with the Flow",
          url : "https://images-assets.nasa.gov/image/PIA06576/PIA06576~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - What\'s Going on with the Hole in the Ozone Layer",
          url : "https://images-assets.nasa.gov/video/What\'s Going on with the Hole in the Ozone Layer_ - Horizontal Video/What\'s Going on with the Hole in the Ozone Layer_ - Horizontal Video~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - Merry-Go-Round",
          url : "https://images-assets.nasa.gov/image/PIA05594/PIA05594~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - Places to Go, Things to See",
          url : "https://images-assets.nasa.gov/image/PIA11750/PIA11750~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - Way to Go Spirit!",
          url : "https://images-assets.nasa.gov/image/PIA06686/PIA06686~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - Hey! Whered Everybody Go?",
          url : "https://images-assets.nasa.gov/image/PIA17988/PIA17988~thumb.jpg",
          explanation : nil),
        Photo(
          title : "MOCK - #AskNASA - Who Is Going With Us?",
          url : "https://images-assets.nasa.gov/video/NHQ_0219_1014_AskNASA - Who Is Going With Us/NHQ_0219_1014_AskNASA - Who Is Going With Us~thumb.jpg",
          explanation : nil)
    ]
    
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
        //startFetch()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.PhotoResultDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.array = self.imagesListService.photos
            self.collectionView.reloadData()
            self.scrollToFirstRow()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
}

private extension MainViewController {
    func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.collectionView.scrollToItem(at: indexPath as IndexPath, at: .top, animated: true)
    }
    
    func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(MainCollectionViewCell.self, forCellWithReuseIdentifier: MainCollectionViewCell.cellReuseIdentifier)
    }
    
    func startFetch() {
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let imageURLString = array[indexPath.row].url
        let viewController = SingleImageViewController(imageURLString: imageURLString)
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
                height: cellHeight)
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

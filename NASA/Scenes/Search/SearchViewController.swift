import UIKit
import Kingfisher

class SearchViewController: UIViewController {
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var uiBlockingProgressHUD: UIBlockingProgressHUDProtocol?
    private var fullScreenTransitionManager: FullScreenTransitionManager?
    
    private lazy var nasaArray: [Photo] = []
    
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.backgroundColor = UIColor.black
        bar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        return bar
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.placeholder = "Search"
        search.frame = CGRect(x: 10, y: 50, width: view.frame.width - 20, height: 50)
        return search
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func loadView() {
        super.loadView()
        alertPresenter = AlertPresenterImpl(viewController: self)
        uiBlockingProgressHUD = UIBlockingProgressHUD(viewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blackColor
        view.addSubview(navigationBar)
        navigationBar.addSubview(searchBar)
        searchBar.delegate = self
        configureTableView()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.SearchResultDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.nasaArray = self.imagesListService.found
            self.tableView.reloadData()
            self.scrollToFirstRow()
        }
    }
    
    private func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: 0, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: true)
    }
    
    private func configureTableView() {
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellReuseIdentifier)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func startFetchUsing(searchText: String?) {
        guard let searchText = searchText else { return }
        uiBlockingProgressHUD?.showCustom()
        imagesListService.fetchPhotosUsing(searchText: searchText) { [weak self] result in
            guard let self = self else { return }
            self.uiBlockingProgressHUD?.dismissCustom()
            switch result {
            case .success:
                return
            case .failure:
                self.showNetWorkErrorForImagesListVC() {
                    self.startFetchUsing(searchText: searchText)
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

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let seconds = 1.0
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) { [weak self] in
            guard let self = self else { return }
            if searchText == searchBar.text && searchBar.text != "" {
                self.startFetchUsing(searchText: searchText)
            }
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.resignFirstResponder()
        searchBar.text = ""
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tag = indexPath.row + 1
        let photo = nasaArray[indexPath.row]
        let fullScreenTransitionManager = FullScreenTransitionManager(anchorViewTag: tag)
        let fullScreenImageViewController = FullScreenImageViewController(photo: photo, tag: tag)
        fullScreenImageViewController.modalPresentationStyle = .custom
        fullScreenImageViewController.transitioningDelegate = fullScreenTransitionManager
        present(fullScreenImageViewController, animated: true)
        self.fullScreenTransitionManager = fullScreenTransitionManager
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nasaArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellReuseIdentifier, for: indexPath) as? SearchTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(
            textLabel: nasaArray[indexPath.row].title
        )
        downloadImageFor(cell: cell, at: indexPath)
        setupGradientFor(cell: cell)
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    private func downloadImageFor(cell: SearchTableViewCell, at indexPath: IndexPath) {
        guard let url = self.nasaArray[indexPath.row].url.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed
        )
        else { return }
        let processor = DownsamplingImageProcessor(size: CGSize(width: 190, height: 190))
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
                cell.cellImageView.image = UIImage(systemName: "nosign") ?? UIImage()
            }
            
        }
    }
    
    private func setupGradientFor(cell: SearchTableViewCell) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 160, width: view.frame.width-20, height: 30)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.75).cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        cell.cellImageView.layer.addSublayer(gradientLayer)
    }
}


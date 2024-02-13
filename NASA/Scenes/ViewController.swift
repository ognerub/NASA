import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    private let storage = OAuth2TokenStorage.shared
    
    private lazy var nasaArray: [Photo] = []
    
    private lazy var navigationBar: UINavigationBar = {
        let bar = UINavigationBar()
        bar.backgroundColor = UIColor.grayColor
        bar.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        return bar
    }()
    
    private lazy var searchBar: UISearchBar = {
        let search = UISearchBar()
        search.barStyle = .black
        search.placeholder = "Search"
        search.frame = CGRect(x: 10, y: 50, width: view.frame.width - 20, height: 50)
        return search
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.allowsSelection = false
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()

    override func loadView() {
        super.loadView()
        alertPresenter = AlertPresenterImpl(viewController: self)
        if storage.token == nil {
            print("token is nil write")
            storage.token = NetworkConfiguration.standart.personalToken
        } else {
            print("token not nil")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(navigationBar)
        navigationBar.addSubview(searchBar)
        searchBar.delegate = self
        configureTableView()
        
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.DidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self = self else { return }
            self.nasaArray = self.imagesListService.photos
            self.tableView.reloadData()
        }
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
        UIBlockingProgressHUD.showCustom()
        imagesListService.fetchPhotos(searchText: searchText) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismissCustom()
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

extension ViewController: UISearchBarDelegate {
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}

extension ViewController: UITableViewDataSource {
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
            placeholder: UIImage(systemName: "sun"),
            options: [
                .processor(processor)
            ]
        ) { [weak self] result in
            guard let self = self else { return }
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
        gradientLayer.frame = CGRect(x: 0, y: 165, width: view.frame.width-20, height: 25)
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        cell.cellImageView.layer.addSublayer(gradientLayer)
    }
}


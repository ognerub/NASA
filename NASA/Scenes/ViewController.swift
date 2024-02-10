import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    
    private let storage = OAuth2TokenStorage.shared
    
    private lazy var nasaArray: [Photo] = []
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.backgroundColor = UIColor.green
        table.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        return table
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.addTarget(
            self,
            action: #selector(buttonPressed),
            for: .touchUpInside)
        button.backgroundColor = .lightGray
        button.setTitle("Load!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.frame = CGRect(x: view.frame.width/2-100, y: view.frame.height/2-50, width: 200, height: 100)
        return button
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
        view.backgroundColor = .red
        view.addSubview(tableView)
        view.addSubview(button)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.cellReuseIdentifier)
        
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
    
    @objc
    private func buttonPressed() {
        UIBlockingProgressHUD.showCustom()
        imagesListService.fetchPhotos { result in
            UIBlockingProgressHUD.dismissCustom()
            switch result {
            case .success:
                return
            case .failure:
                self.showNetWorkErrorForImagesListVC() {
                    self.buttonPressed()
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

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nasaArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.cellReuseIdentifier, for: indexPath) as? SearchTableViewCell else {
            print("return default cell")
            return UITableViewCell()
        }
        cell.configureCell(
            textLabel: nasaArray[indexPath.row].title
        )
        downloadImageFor(cell: cell, at: indexPath)
        return cell
    }
    
    private func downloadImageFor(cell: SearchTableViewCell, at indexPath: IndexPath) {
        cell.cellImageView.kf.setImage(with: URL(string: self.nasaArray[indexPath.row].url), placeholder: UIImage(systemName: "sun"), options: [.scaleFactor(0.5)]) { result in
            switch result {
            case .success(_):
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case .failure(_):
                print("failed to load image!")
            }
        }
    }
}


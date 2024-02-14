import UIKit
import Kingfisher
final class SingleImageViewController: UIViewController {
    
    private let array: [Int] = [1,2,3,4,5,6,7,8,9,10]
    
    private lazy var titleBackgroundView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.clear.cgColor
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 80)
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.backward"), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.blackColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var imageURLString: String
    
    private lazy var singleImageView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    init(imageURLString: String) {
        self.imageURLString = imageURLString
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
        configureTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadImageFor(imageView: singleImageView)
    }
    
    @objc
    private func backButtonTapped() {
        let mainViewController = MainViewController()
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        navigationController?.view.layer.add(transition, forKey: kCATransition)
        navigationController?.pushViewController(mainViewController, animated: true)
    }
}

private extension SingleImageViewController {
    func downloadImageFor(imageView: UIImageView) {
        guard let url = imageURLString.addingPercentEncoding(
            withAllowedCharacters: .urlQueryAllowed)
        else { return }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(),
            options: []
        ) { result in
            switch result {
            case .success(_):
                imageView.contentMode = .scaleAspectFill
            case .failure(_):
                imageView.image = UIImage(systemName: "nosign") ?? UIImage()
            }
            
        }
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    func configureConstraints() {
        view.addSubview(singleImageView)
        NSLayoutConstraint.activate([
            singleImageView.heightAnchor.constraint(equalToConstant: 300),
            singleImageView.topAnchor.constraint(equalTo: view.topAnchor),
            singleImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            singleImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        view.addSubview(titleBackgroundView)
        titleBackgroundView.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.heightAnchor.constraint(equalToConstant: 42),
            backButton.widthAnchor.constraint(equalToConstant: 42),
            backButton.leadingAnchor.constraint(equalTo: titleBackgroundView.leadingAnchor),
            backButton.bottomAnchor.constraint(equalTo: titleBackgroundView.bottomAnchor)
        ])
    }
}

extension SingleImageViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

extension SingleImageViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? UITableViewCell else { return UITableViewCell() }
        cell.textLabel?.text = String(array[indexPath.row])
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
        return cell
    }
}

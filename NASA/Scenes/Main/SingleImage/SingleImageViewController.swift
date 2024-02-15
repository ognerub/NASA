import UIKit
import Kingfisher
final class SingleImageViewController: UITableViewController {
    
    private lazy var titleBackgroundView: UIView = {
        let view = UIView()
        view.layer.backgroundColor = UIColor.clear.cgColor
        view.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 42)
        return view
    }()

    private lazy var backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Back", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.titleLabel?.textColor = UIColor.whiteColor
        button.contentHorizontalAlignment = .left
        button.setImage(UIImage.backward, for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        button.tintColor = UIColor.white
        button.layer.shadowColor = UIColor.blackColor.cgColor
        button.layer.shadowOffset = CGSize(width: 2, height: 2)
        button.layer.shadowRadius = 2
        button.layer.shadowOpacity = 0.5
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var imageURLString: String
    
    private let imageTitle: String
    
    private let explanation: String
    
    private let tableHeaderView: StretchyTableHeaderView
    
    private let currentCellIndex: IndexPath
    
    init(
        imageURLString: String,
        imageTitle: String,
        explanation: String,
        tableHeaderView: StretchyTableHeaderView,
        currentCellIndex: IndexPath
    ) {
        self.imageURLString = imageURLString
        self.imageTitle = imageTitle
        self.explanation = explanation
        self.tableHeaderView =
        SingleImageTableHeaderView(
            imageURLString: self.imageURLString,
            frame: CGRect(
                origin: .zero,
                size: CGSize(
                    width: .zero,
                    height: SingleImageTableHeaderView.baseHeight
                )
            )
        )
        self.currentCellIndex = currentCellIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureConstraints()
    }
    
    @objc
    private func backButtonTapped() {
        let cellIndex = currentCellIndex
        let mainViewController = MainViewController(currentCellIndex: cellIndex)
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
    
    func configureTableView() {
        tableView.register(SingleImageTableViewCell.self, forCellReuseIdentifier: SingleImageTableViewCell.cellReuseIdentifier)
        tableView.tableHeaderView = tableHeaderView
    }
    
    func configureConstraints() {
        view.addSubview(titleBackgroundView)
        titleBackgroundView.addSubview(backButton)
        NSLayoutConstraint.activate([
            backButton.heightAnchor.constraint(equalToConstant: 42),
            backButton.widthAnchor.constraint(equalToConstant: 150),
            backButton.leadingAnchor.constraint(equalTo: titleBackgroundView.leadingAnchor, constant: 10),
            backButton.bottomAnchor.constraint(equalTo: titleBackgroundView.bottomAnchor)
        ])
    }
}

// MARK: UIScrollViewDelegate

extension SingleImageViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        tableHeaderView.scrollViewDidScroll(scrollView)
    }
}

extension SingleImageViewController {
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension SingleImageViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SingleImageTableViewCell.cellReuseIdentifier, for: indexPath) as? SingleImageTableViewCell else { return UITableViewCell() }
        cell.configureCell(title: imageTitle,text: explanation)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.layoutIfNeeded()
    }
}

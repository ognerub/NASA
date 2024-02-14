import UIKit
import Kingfisher
final class SingleImageViewController: UIViewController {
    
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
        view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        view.backgroundColor = .red
        configureConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadImageFor(imageView: singleImageView)
    }
    
    private func downloadImageFor(imageView: UIImageView) {
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

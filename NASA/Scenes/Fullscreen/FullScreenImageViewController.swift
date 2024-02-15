import UIKit
import Kingfisher
import TinyConstraints

class FullScreenImageViewController: UIViewController {
    private let octocatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.setHugging(.defaultHigh, for: .horizontal)
        imageView.setCompressionResistance(.defaultHigh, for: .horizontal)
        return imageView
    }()

    private lazy var imageViewLandscapeConstraint = octocatImageView.heightToSuperview(isActive: false, usingSafeArea: true)
    private lazy var imageViewPortraitConstraint = octocatImageView.widthToSuperview(isActive: false, usingSafeArea: true)
    
    private let photo: Photo

    init(photo: Photo, tag: Int) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
        octocatImageView.tag = tag
        octocatImageView.image = UIImage(contentsOfFile: photo.url)
        downloadImageFor(imageView: octocatImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .clear

        view.addSubview(octocatImageView)

        octocatImageView.centerInSuperview()

        // Constraint UIImageView to fit the aspect ratio of the containing image
        let aspectRatio = octocatImageView.intrinsicContentSize.height / octocatImageView.intrinsicContentSize.width
        octocatImageView.heightToWidth(of: octocatImageView, multiplier: aspectRatio)
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollectionChanged(from: previousTraitCollection)
    }

    private func traitCollectionChanged(from previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass != .compact {
            // Ladscape
            imageViewPortraitConstraint.isActive = false
            imageViewLandscapeConstraint.isActive = true
        } else {
            // Portrait
            imageViewLandscapeConstraint.isActive = false
            imageViewPortraitConstraint.isActive = true
        }
    }
    
    private func downloadImageFor(imageView: UIImageView) {
        guard let url = photo.url.addingPercentEncoding(
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
}

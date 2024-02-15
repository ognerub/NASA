import UIKit
import Kingfisher

final class SingleImageTableHeaderView: StretchyTableHeaderView {
    
    static let baseHeight: CGFloat = 250
    
    private var imageURLString: String
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "moon"))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    init(imageURLString: String, frame: CGRect) {
        self.imageURLString = imageURLString
        super.init(frame: frame)
        configureUI()
        downloadImageFor(imageView: imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        contentView.addSubview(imageView)
        imageView.edgesToSuperview()
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
}

import UIKit

enum MainCollectionViewCellConstants {
    static let cellHeight: CGFloat = 150
    static let cellsInRow: CGFloat = 3
    static let spacing: CGFloat = 5
    static let insets: CGFloat = 10
}

final class MainCollectionViewCell: UICollectionViewCell {
    
    static let cellReuseIdentifier = "MainCollectionViewCell"
    
    lazy var cellView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var cellImageView: UIImageView = {
        let image = UIImage()
        let view = UIImageView(image: image)
        view.backgroundColor = .clear
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureConstraints()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        contentView.addSubview(cellView)
        NSLayoutConstraint.activate([
            cellView.topAnchor.constraint(equalTo: topAnchor),
            cellView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellView.trailingAnchor.constraint(equalTo: trailingAnchor),
            cellView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        cellView.addSubview(cellImageView)
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: cellView.topAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: cellView.leadingAnchor),
            cellImageView.trailingAnchor.constraint(equalTo: cellView.trailingAnchor),
            cellImageView.bottomAnchor.constraint(equalTo: cellView.bottomAnchor)
        ])
    }
    
}

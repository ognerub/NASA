import UIKit

final class MainCollectionViewCell: UICollectionViewCell {
    
    static let cellReuseIdentifier = "MainCollectionViewCell"
    
    private lazy var cellLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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
    
    func configureCell(text: String) {
        self.cellLabel.text = text
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
        cellView.addSubview(cellLabel)
        NSLayoutConstraint.activate([
            cellLabel.bottomAnchor.constraint(equalTo: cellView.bottomAnchor, constant: -10),
            cellLabel.leadingAnchor.constraint(equalTo: cellView.leadingAnchor, constant: 10),
            cellLabel.trailingAnchor.constraint(equalTo: cellView.trailingAnchor, constant: -10)
        ])
    }
    
}

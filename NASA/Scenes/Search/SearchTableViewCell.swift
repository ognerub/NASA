import UIKit

final class SearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let cellReuseIdentifier = "SearchTableViewCell"
    
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
    
    lazy var cellImageView: UIImageView = {
        let image = UIImage()
        let view = UIImageView(image: image)
        view.backgroundColor = .clear
        view.contentMode = .scaleToFill
        view.layer.cornerRadius = 15
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
    }
    
    func configureCell(
        textLabel: String
    ) {
        cellLabel.text = textLabel
    }
    
    // MARK: - Configure constraints
    
    private func configureConstraints() {
        addSubview(cellImageView)
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            cellImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cellImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            cellImageView.heightAnchor.constraint(greaterThanOrEqualToConstant: 190)
        ])
        addSubview(cellLabel)
        NSLayoutConstraint.activate([
            cellLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20)
        ])
    }
}

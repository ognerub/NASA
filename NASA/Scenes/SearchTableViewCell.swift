import UIKit

final class SearchTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let cellReuseIdentifier = "cell"
    
    private lazy var cellLabel: UILabel = {
        let label = UILabel()
        label.text = "String"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cellImageView: UIImageView = {
        let image = UIImage(systemName: "moon")
        let view = UIImageView(image: image)
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureConstraints()
        backgroundColor = .yellow
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.kf.cancelDownloadTask()
    }
    
    func configureCell(textLabel: String) {
        cellLabel.text = textLabel
    }
    
    // MARK: - Configure constraints
    
    private func configureConstraints() {
        addSubview(cellLabel)
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
        addSubview(cellImageView)
        NSLayoutConstraint.activate([
            cellImageView.topAnchor.constraint(equalTo: topAnchor),
            cellImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellImageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

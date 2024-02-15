import UIKit

final class SingleImageTableViewCell: UITableViewCell {
    
    static let cellReuseIdentifier = "SingleImageTableViewCell"
    
    private lazy var cellLabel: UILabel = {
        let text = UILabel()
        text.text = "sdfdsfds"
        text.textColor = .white
        text.textAlignment = .justified
        text.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 0
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(text: String) {
        self.cellLabel.text = text
    }
    
    private func configureConstraints() {
        addSubview(cellLabel)
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: topAnchor),
            cellLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
}

import UIKit

final class SingleImageTableViewCell: UITableViewCell {
    
    static let cellReuseIdentifier = "SingleImageTableViewCell"
    
    private lazy var cellTitle: UILabel = {
        let text = UILabel()
        text.textColor = .white
        text.textAlignment = .left
        text.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        text.lineBreakMode = .byWordWrapping
        text.numberOfLines = 0
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private lazy var cellLabel: UILabel = {
        let text = UILabel()
        text.textColor = .white
        text.textAlignment = .justified
        text.font = UIFont.systemFont(ofSize: 20, weight: .regular)
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
    
    func configureCell(title: String, text: String) {
        self.cellTitle.text = title
        self.cellLabel.text = text
    }
    
    private func configureConstraints() {
        addSubview(cellTitle)
        NSLayoutConstraint.activate([
            cellTitle.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            cellTitle.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cellTitle.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            cellTitle.heightAnchor.constraint(equalToConstant: 60)
        ])
        addSubview(cellLabel)
        NSLayoutConstraint.activate([
            cellLabel.topAnchor.constraint(equalTo: cellTitle.bottomAnchor, constant: 10),
            cellLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            cellLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            cellLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }
    
}

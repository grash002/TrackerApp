import UIKit

final class HabitCreatingCell: UITableViewCell {
    
    // MARK: - Public Properties
    static let identifier = "HabitCreatingCell"
    
    // MARK: - Private Properties
    private let mainLabel = UILabel()
    private let subLabel = UILabel()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        //contentView.backgroundColor = UIColor(named: "BackGroundFields")
        
        mainLabel.font = UIFont.systemFont(ofSize: 17)
        mainLabel.textColor = .label
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subLabel.font = UIFont.systemFont(ofSize: 17)
        subLabel.textColor = .lightGray
        subLabel.isHidden = true
        subLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [mainLabel, subLabel])
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor),
            stackView.centerYAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerYAnchor)
        ])
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(mainText: String, subText: String?) {
        mainLabel.text = mainText
        mainLabel.isHidden = false
        if let subText = subText, !subText.isEmpty {
            subLabel.text = subText
            subLabel.isHidden = false
        } else {
            subLabel.isHidden = true 
        }
    }
}

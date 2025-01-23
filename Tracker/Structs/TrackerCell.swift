import UIKit

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    static let identifier = "trackerCell"
    var saveCountDays: ((Bool) -> Void)?
    
    let viewCardTracker = UIView()
    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor(named: "backGround")
        label.textAlignment = .center
        return label
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self,
                         action: #selector(addButtonDidTap),
                         for: .touchUpInside)
        return button
    }()
    
    // MARK: - Private Properties
    private var trackerCellColor: UIColor = .white
    private var countDays: Int = 0
    private var addButtonDidTapFlag = false
    lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .black
        label.text = "0 дней"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = .clear
        
        viewCardTracker.backgroundColor = self.trackerCellColor
        viewCardTracker.layer.cornerRadius = 16
        viewCardTracker.translatesAutoresizingMaskIntoConstraints = false
        
        viewCardTracker.addSubview(emojiLabel)
        viewCardTracker.addSubview(titleLabel)
        contentView.addSubview(viewCardTracker)
        contentView.addSubview(daysLabel)
        contentView.addSubview(addButton)
        
        NSLayoutConstraint.activate([
            viewCardTracker.topAnchor.constraint(equalTo: contentView.topAnchor),
            viewCardTracker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            viewCardTracker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            viewCardTracker.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: viewCardTracker.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: viewCardTracker.leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            titleLabel.leadingAnchor.constraint(equalTo: viewCardTracker.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: viewCardTracker.trailingAnchor, constant: -12),
            titleLabel.bottomAnchor.constraint(equalTo: viewCardTracker.bottomAnchor, constant: 0),
            titleLabel.topAnchor.constraint(lessThanOrEqualTo: emojiLabel.bottomAnchor),
            
            daysLabel.topAnchor.constraint(equalTo: viewCardTracker.bottomAnchor, constant: 8),
            daysLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),
            daysLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
            addButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.centerYAnchor.constraint(equalTo: daysLabel.centerYAnchor)
        ])
        
        
        
        addButton.layer.cornerRadius = 17
        addButton.layer.masksToBounds = true
        emojiLabel.layer.cornerRadius = 12
        emojiLabel.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(nameTracker: String, emoji: String, color: UIColor, isDidTap: Bool, count: Int, isDisableAddButton: Bool, closure: @escaping ((Bool) -> Void)) {
        emojiLabel.text = emoji
        titleLabel.text = nameTracker
        viewCardTracker.backgroundColor = color
        addButton.backgroundColor = color
        saveCountDays = closure
        countDays = count
        daysLabel.text = dateText(from: countDays)
        addButtonDidTapFlag = isDidTap
        
        if addButtonDidTapFlag {
            addButton.setTitle("", for: .normal)
            addButton.setImage(UIImage(named: "Done"), for: .normal)
            addButton.alpha = 0.7
        } else {
            self.addButton.setTitle("+", for: .normal)
            self.addButton.setImage(UIImage(), for: .normal)
            self.addButton.alpha = 1
        }
        if isDisableAddButton {
            addButton.isEnabled = false
        } else {
            addButton.isEnabled = true
        }
        
    }
    
    // MARK: - Private Methods
    private func dateText(from number: Int) -> String {
        let lastDigit = number % 10
        let lastTwoDigits = number % 100
        
        if (11...14).contains(lastTwoDigits) {
            return "\(number) дней"
        }
        
        switch lastDigit {
        case 1:
            return "\(number) день"
        case 2...4:
            return "\(number) дня"
        default:
            return "\(number) дней"
        }
    }
    
    @objc
    private func addButtonDidTap() {
        saveCountDays?(addButtonDidTapFlag)
    }
}

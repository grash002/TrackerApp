import UIKit

final class TrackerCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    static let identifier = "trackerCell"
    var saveCountDays: ((Bool) -> Void)?
    var onTapMenuPin: (()-> Void)?
    var onTapMenuEdit: (()-> Void)?
    var onTapMenuDelete: (()-> Void)?
    
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
        button.setTitleColor(.systemBackground, for: .normal)
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
    private var pinnedFlag = false
    
    lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .label
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
        
        let interaction = UIContextMenuInteraction(delegate: self)
        viewCardTracker.addInteraction(interaction)
        
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
    
    func configure(nameTracker: String, 
                   emoji: String,
                   color: UIColor,
                   isDidTap: Bool, 
                   count: Int,
                   isDisableAddButton: Bool,
                   pinnedFlag: Bool,
                   onSaveCountDays: @escaping ((Bool) -> Void),
                   onTapMenuPin: @escaping (()-> Void),
                   onTapMenuEdit: @escaping (()-> Void),
                   onTapMenuDelete: @escaping (()-> Void)) {
        emojiLabel.text = emoji
        titleLabel.text = nameTracker
        viewCardTracker.backgroundColor = color
        addButton.backgroundColor = color
        saveCountDays = onSaveCountDays
        countDays = count
        daysLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of tracking days"),
            countDays
        )
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
        
        self.pinnedFlag = pinnedFlag
        
        self.onTapMenuPin = onTapMenuPin
        self.onTapMenuEdit = onTapMenuEdit
        self.onTapMenuDelete = onTapMenuDelete
    }
    
    // MARK: - Private Methods
    @objc
    private func addButtonDidTap() {
        saveCountDays?(addButtonDidTapFlag)
    }
}

extension TrackerCell: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) {[weak self] _ in
            guard let self else { return UIMenu()}
            let pinAction = UIAction(title: self.pinnedFlag ? NSLocalizedString("TrackerCell.action.unpin", comment: "") : NSLocalizedString("TrackerCell.action.pin", comment: "")) { [weak self] _ in
                self?.onTapMenuPin?()
            }
            
            let editAction = UIAction(title : NSLocalizedString("TrackerCell.action.edit", comment: "")) { [weak self] _ in
                self?.onTapMenuEdit?()
            }

            let deleteAction = UIAction(title: NSLocalizedString("TrackerCell.action.delete", comment: ""), attributes: .destructive) { [weak self] _ in
                self?.onTapMenuDelete?()
            }

            return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
        }
    }
}

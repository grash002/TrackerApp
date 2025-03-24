import UIKit

final class CreatingEmojiColorCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    static let identifier = "CreatingEmojiColorCell"
    
    override var isSelected: Bool {
        didSet {
            UIView.animate(withDuration: 0.2) {
                self.contentView.backgroundColor = self.isSelected && self.colorView.isHidden ? UIColor(named: "BackGroundFields") : .clear
                
                if self.isSelected && self.label.isHidden {
                    self.contentView.layer.borderWidth = 3
                    self.contentView.layer.borderColor = self.colorView.backgroundColor?.withAlphaComponent(0.3).cgColor
                } else {
                    self.contentView.layer.borderWidth = 0
                }
            }
        }
    }
    
    // MARK: - Private Properties
    private lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        return label
    }()
    private lazy var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }()
    private var color: UIColor?
    private lazy var labelConstraints = [
        label.heightAnchor.constraint(equalToConstant: 40),
        label.widthAnchor.constraint(equalToConstant: 40),
        label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ]
    private lazy var colorViewConstraints = [
        colorView.heightAnchor.constraint(equalToConstant: 40),
        colorView.widthAnchor.constraint(equalToConstant: 40),
        colorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
        colorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
    ]
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 16
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(labelText: String?, backGroundColor: UIColor?){
        self.label.text = labelText
        colorView.backgroundColor = backGroundColor
        
        if backGroundColor != nil {
            colorView.isHidden = false
            label.isHidden = true
            NSLayoutConstraint.activate(colorViewConstraints)
            NSLayoutConstraint.deactivate(labelConstraints)
        } else {
            colorView.isHidden = true
            label.isHidden = false
            NSLayoutConstraint.activate(labelConstraints)
            NSLayoutConstraint.deactivate(colorViewConstraints)
        }
    }
}

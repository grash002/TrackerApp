import UIKit

final class ScheduleCell: UITableViewCell {
    
    // MARK: - Public Properties
    static let identifier = "ScheduleCell"
    var indexRow: Int?
    var switchChanged: ((Bool, Int) -> Void)?
    
    // MARK: - Private Properties
    private let label = UILabel()
    private let switcher = UISwitch()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        
        switcher.addTarget(self,
                           action: #selector(switcherDidTap),
                           for: .touchUpInside)
        switcher.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [label, switcher])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16 ),
            stackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 15),
            stackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -15),
        ])
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(text: String, indexRow: Int, switchChangedClosure: ((Bool, Int) -> Void)?) {
        self.label.text = text
        self.indexRow = indexRow
        self.switchChanged = switchChangedClosure
    }
    
    // MARK: - Private Methods
    @objc 
    private func switcherDidTap() {
        guard let indexRow else { return }
        switchChanged?(switcher.isOn, indexRow)
    }
}

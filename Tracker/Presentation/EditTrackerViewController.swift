import UIKit

final class EditTrackerViewController: CreatingViewController {
    
    // MARK: - Private properties
    private let tracker: Tracker
    private let categoryName: String
    private let countDays: Int
    private var habitFlag: Bool = false
    
    // MARK: - Initializers
    init(tracker: Tracker, categoryName: String, countDays: Int) {
        self.tracker = tracker
        self.categoryName = categoryName
        self.countDays = countDays
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        titleLabel.text = NSLocalizedString("creatingView.EditTrackerTitle", comment: "")
        habitFlag = tracker.schedule != Schedule(days: [.eternity])
        tableViewButtonsHeight = habitFlag ? 150 : 75
        super.viewDidLoad()
        addDayLabel(countDays)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        enterFields()
        analyticsService.report(event: AnalyticEvents.open.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: AnalyticEvents.close.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    @objc
    override func createButtonDidTap() {
        guard let text = textField.text,
              let selectedSchedule ,
              let selectedEmoji,
              let selectedColor else { return }
        
        let newTracker = Tracker(id: tracker.id, name: text, colorHex: selectedColor, emoji: selectedEmoji, schedule: selectedSchedule, pinnedFlag: tracker.pinnedFlag)
        addTracker(tracker: newTracker, toCategory: selectedCategory ?? "")
        
        dismiss(animated: true)
    }
    
    
    // MARK: - Private methods
    private func addDayLabel(_ countDays: Int) {
        NSLayoutConstraint.deactivate([textFieldTopAnchorConstraint!])
        
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .label
        label.text = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of tracking days"),
            countDays
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 38),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textField.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 40)
        ])
    }
    
    private func enterFields() {
        textField.text = tracker.name
        
        selectSchedule(schedule: tracker.schedule)
        
        selectCategory(categoryTitle: categoryName)
        
        if let indexEmoji = emojiList.firstIndex(where: {$0 == tracker.emoji }),
           let indexColor = colorList.firstIndex(where: {$0 == tracker.colorHex }) {
            let indexPathEmoji = IndexPath(row: indexEmoji, section: 0)
            let indexPathColor = IndexPath(row: indexColor, section: 1)
            
            collectionView.selectItem(at: indexPathEmoji, animated: true, scrollPosition: [])
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPathEmoji)
            
            collectionView.selectItem(at: indexPathColor, animated: true, scrollPosition: [])
            collectionView.delegate?.collectionView?(collectionView, didSelectItemAt: indexPathColor)
        }
    }
}

// MARK: - Extension
extension EditTrackerViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        habitFlag ? 2 : 1
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        habitFlag ? 2 : 1
    }
}

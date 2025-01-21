import UIKit

final class HabitCreatingViewController: UIViewController, UITextFieldDelegate {
    // MARK: - Public Properties
    var delegate: TrackersViewController?

    // MARK: - Private Properties
    private let textField = UITextField()
    private let tableViewButtons = UITableView()
    private let createButton = UIButton(type: .custom)
    private let dismissButton = UIButton(type: .custom)
    private let warningLabel = UILabel()
    private let characterLimit = 38
    private var tableViewTopConstraint: NSLayoutConstraint!
    private var selectedCategory: String?
    private var selectedSchedule: Schedule?
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }

    // MARK: - Public Methods
    
    func addTracker(tracker: Tracker, toCategory: String){
        guard let delegate else { return }
        
        if let existingCategoryIndex = delegate.categories.firstIndex(where: { $0.title == toCategory }) {
            delegate.categories[existingCategoryIndex].trackers.append(tracker)
            delegate.refreshTrackersConstraints()
            
        } else {
            let newCategory = TrackerCategory(title: toCategory,
                                          trackers: [tracker])
            delegate.categories.append(newCategory)
            delegate.refreshTrackersConstraints()
        }
    }
    
    func addCategory(toCategory: String){
        guard let delegate else { return }
        if !delegate.categories.contains(where: {$0.title.uppercased() == toCategory.uppercased()}) {
            let newCategory = TrackerCategory(title: toCategory,
                                          trackers: [])
            delegate.categories.append(newCategory)
        }
    }
    
    func selectSchedule(schedule: Schedule) {
        selectedSchedule = schedule
        tableViewButtons.reloadSections(IndexSet(integer: 0), with: .automatic)
        tableViewButtons.separatorStyle = .singleLine
        if selectedSchedule != nil {
            enableButtonWithCond()
        } else {
            disableButton()
        }
    }
    
    func selectCategory(categoryTitle: String){
        selectedCategory = categoryTitle
        tableViewButtons.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        enableButtonWithCond()
    }
    
    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = .white
        
        tableViewButtons.dataSource = self
        tableViewButtons.delegate = self
        tableViewButtons.register(HabitCreatingCell.self,
                                  forCellReuseIdentifier: HabitCreatingCell.identifier)
        tableViewButtons.translatesAutoresizingMaskIntoConstraints = false
        tableViewButtons.backgroundColor = UIColor(named: "BackGroundFields")
        tableViewButtons.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableViewButtons.tableFooterView = UIView()
        tableViewButtons.separatorStyle = .singleLine
        tableViewButtons.layer.cornerRadius = 16
        tableViewButtons.isScrollEnabled = false
        tableViewButtons.separatorInset = UIEdgeInsets(top: 0,
                                                       left: 16,
                                                       bottom: 0,
                                                       right: 16)
        view.addSubview(tableViewButtons)
        
        let titlelLabel = UILabel()
        titlelLabel.text = "Новая привычка"
        titlelLabel.textAlignment = .center
        titlelLabel.font = UIFont.systemFont(ofSize: 16)
        titlelLabel.textColor = .black
        titlelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titlelLabel)
        
        
        textField.placeholder = "Введите название трекера"
        textField.leftView = UIView(frame:
                                        CGRect(x: 0,
                                               y: 0,
                                               width: 16,
                                               height: textField.frame.height))
        textField.leftViewMode = .always
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.layer.cornerRadius = 16
        textField.backgroundColor = UIColor(named: "BackGroundFields")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.delegate = self
        textField.addTarget(self,
                            action: #selector(textFieldDidChange),
                            for: .editingChanged)
        view.addSubview(textField)
        
        warningLabel.text = "Ограничение \(characterLimit) символов"
        warningLabel.textColor = .red
        warningLabel.font = UIFont.systemFont(ofSize: 17)
        warningLabel.textAlignment = .center
        warningLabel.isHidden = true
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(warningLabel)
        
        createButton.setTitle("Создать", for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.tintColor = .white
        createButton.addTarget(self,
                               action: #selector(createButtonDidTap),
                               for: .touchUpInside)
        disableButton()
        
        dismissButton.setTitle("Отменить", for: .normal)
        dismissButton.layer.cornerRadius = 16
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        dismissButton.setTitleColor(.red, for: .normal)
        dismissButton.layer.borderColor = CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        dismissButton.layer.borderWidth = 1
        dismissButton.addTarget(self,
                                action: #selector(dismissButtonDidTap),
                                for: .touchUpInside)
        
        let footerButtonsStack = UIStackView(arrangedSubviews: [dismissButton, createButton])
        footerButtonsStack.axis = .horizontal
        footerButtonsStack.spacing = 8
        footerButtonsStack.distribution = .fillEqually
        footerButtonsStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(footerButtonsStack)
        
        tableViewTopConstraint = tableViewButtons.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([
            titlelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titlelLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titlelLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.topAnchor.constraint(equalTo: titlelLabel.bottomAnchor, constant: 28),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 28),
            warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -28),
            
            tableViewTopConstraint,
            tableViewButtons.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableViewButtons.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableViewButtons.heightAnchor.constraint(equalToConstant: 150),
            
            footerButtonsStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footerButtonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            footerButtonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            footerButtonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func enableButtonWithCond() {
        if  textField.text != "" &&
            textField.text != nil &&
            selectedCategory != nil &&
                selectedSchedule != nil {
            createButton.backgroundColor = .black
            createButton.isEnabled = true
        }
    }
    
    private func disableButton() {
        createButton.isEnabled = false
        createButton.backgroundColor = .gray
    }
    
    private func updateButtonSpacing(withWarningVisible isVisible: Bool) {
        let additionalSpacing: CGFloat = isVisible ? 32 : 0
        tableViewTopConstraint.constant = additionalSpacing
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded() 
        }
    }
    
    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count ?? 0 >= characterLimit{
            warningLabel.isHidden = false
            updateButtonSpacing(withWarningVisible: true)
        } else {
            updateButtonSpacing(withWarningVisible: false)
            warningLabel.isHidden = true
        }
        
        if let text = textField.text, !text.isEmpty,
           text.count < characterLimit {
            enableButtonWithCond()
        } else {
            disableButton()
        }
    }
    
    @objc
    private func createButtonDidTap() {
        guard let text = textField.text,
        let color = UIColor(named: "YPBlue"),
        let selectedSchedule else { return }
        
        let newTracker = Tracker(id: UUID(), name: text, color: color, emoji: "🏂🏻", schedule: selectedSchedule)
        addTracker(tracker: newTracker, toCategory: selectedCategory ?? "")
        
        self.dismiss(animated: true)
    }
    
    @objc
    private func dismissButtonDidTap() {
        self.dismiss(animated: true)
    }
}

// MARK: - Extensions
extension HabitCreatingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, 
                   numberOfRowsInSection section: Int) -> Int {
        2
    }
    
    func tableView(_ tableView: UITableView, 
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitCreatingCell.identifier,
                                                       for: indexPath) as? HabitCreatingCell else { return UITableViewCell()}
        cell.backgroundColor = UIColor(named: "BackGroundFields")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        let mainText = indexPath.row == 0 ? "Категория" : "Расписание"
        let subText = indexPath.row == 0 ? selectedCategory : selectedSchedule?.toString()
        cell.configure(mainText: mainText, subText: subText)
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
         tableView.deselectRow(at: indexPath, animated: false)
            
            let selectCategoryViewController = SelectCategoryViewController()
            selectCategoryViewController.delegateHabitCreating = self
            selectCategoryViewController.delegateTrackersView = delegate
            self.present(selectCategoryViewController, animated: true)
            
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            let selectScheduleViewController = SelectScheduleViewController()
            selectScheduleViewController.delegate = self
            self.present(selectScheduleViewController, animated: true)
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

}


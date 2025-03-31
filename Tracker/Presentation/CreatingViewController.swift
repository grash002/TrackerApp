import UIKit

class CreatingViewController: UIViewController, UITextFieldDelegate, CreatingViewControllerProtocol {
    // MARK: - Public Properties
    
    let analyticsService = AnalyticsService()
    weak var delegate: TrackersViewController?
    var tableViewButtonsHeight: CGFloat = 150
    var selectedEmoji: String?
    var selectedColor: String?
    var selectedSchedule: Schedule?
    var selectedCategory: String?
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        return titleLabel
    }()
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 2.5
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(CreatingEmojiColorCell.self, forCellWithReuseIdentifier: CreatingEmojiColorCell.identifier)
        collectionView.register(CreatingEmojiColorHeaderCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: CreatingEmojiColorHeaderCell.identifier)
        collectionView.allowsMultipleSelection = true
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        contentView.addSubview(collectionView)
        
        return collectionView
    }()
    let textField = UITextField()
    let contentView = UIView()
    var textFieldTopAnchorConstraint: NSLayoutConstraint?
    
    let emojiList = ["🙂","😻","🌺","🐶","❤️","😱","😇","😡","🥶","🤔","🙌","🍔","🥦","🏓","🥇","🎸","🏝️","😪",]
    let colorList = ["#FD4C49", "#FF881E", "#007BFA", "#6E44FE", "#33CF69", "#E66DD4", "#F9D4D4", "#34A7FE", "#46E69D", "#35347C", "#FF674D", "#FF99CC", "#F6C48B", "#7994F5", "#832CF1", "#AD56DA", "#8D72E6", "#2FD058"]
    
    // MARK: - Private Properties
    private let scrollView = UIScrollView()
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let tableViewButtons = UITableView()
    private let createButton = UIButton(type: .custom)
    private let dismissButton = UIButton(type: .custom)
    private let warningLabel = UILabel()
    private let characterLimit = 38
    private lazy var tableViewTopConstraint: NSLayoutConstraint = {
        tableViewButtons.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 0)
    }()
    
    // MARK: - Override Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        scrollView.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        analyticsService.report(event: AnalyticEvents.open.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: AnalyticEvents.close.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    // MARK: - Public Methods
    func addTracker(tracker: Tracker, toCategory: String){
        guard let delegate else { return }
        
        if let existingCategory = delegate.categories.first(where: { $0.title == toCategory }) {
            trackerCategoryStore.addTrackersCategory(idCategory: existingCategory.id, tracker: tracker)
            delegate.refreshTrackersConstraints()
            
        } else {
            let idCategory = UUID()
            trackerCategoryStore.createTrackerCategory(idCategory: idCategory, categoryName: toCategory)
            
            trackerCategoryStore.addTrackersCategory(idCategory: idCategory, tracker: tracker)
            delegate.refreshTrackersConstraints()
        }
    } 
    
    func addCategory(toCategory: String){
        guard let delegate else { return }
        if !delegate.categories.contains(where: {$0.title.uppercased() == toCategory.uppercased()}) {
            trackerCategoryStore.createTrackerCategory(idCategory: UUID(), categoryName: toCategory)
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
    func setView() {
        textFieldTopAnchorConstraint = textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 28)
        
        contentView.backgroundColor = .systemBackground
        scrollView.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.heightAnchor.constraint(greaterThanOrEqualTo: scrollView.heightAnchor)
        ])
        
        collectionView.reloadData()
        
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
        contentView.addSubview(tableViewButtons)
        
        textField.placeholder = NSLocalizedString("creatingView.textField.placeholder", comment: "")
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
        contentView.addSubview(textField)
        
        warningLabel.text =  String(format: NSLocalizedString("creatingView.warningLabel", comment: ""), characterLimit)
        warningLabel.textColor = .red
        warningLabel.font = UIFont.systemFont(ofSize: 17)
        warningLabel.textAlignment = .center
        warningLabel.isHidden = true
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(warningLabel)
        
        createButton.setTitle(NSLocalizedString("creatingView.creatingButton.title", comment: ""), for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.tintColor = .white
        createButton.addTarget(self,
                               action: #selector(createButtonDidTap),
                               for: .touchUpInside)
        disableButton()
        
        dismissButton.setTitle(NSLocalizedString("creatingView.cancellingButton.title", comment: ""), for: .normal)
        dismissButton.layer.cornerRadius = 16
        dismissButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
        contentView.addSubview(footerButtonsStack)
        
        tableViewTopConstraint = tableViewButtons.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            textFieldTopAnchorConstraint ?? NSLayoutConstraint(),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            warningLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            warningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 28),
            warningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -28),
            
            tableViewTopConstraint,
            tableViewButtons.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableViewButtons.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableViewButtons.heightAnchor.constraint(equalToConstant: tableViewButtonsHeight),
            
            collectionView.topAnchor.constraint(equalTo: tableViewButtons.bottomAnchor, constant: 32),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionView.bottomAnchor.constraint(equalTo: footerButtonsStack.topAnchor, constant: 0),
            collectionView.heightAnchor.constraint(equalToConstant: 528),
            
            footerButtonsStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            footerButtonsStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            footerButtonsStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            footerButtonsStack.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func enableButtonWithCond() {
        if  textField.text != "" &&
                textField.text != nil &&
                selectedCategory != nil &&
                selectedSchedule != nil &&
                selectedColor != nil &&
                selectedEmoji != nil {
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
    func createButtonDidTap() {
        guard let text = textField.text,
              let selectedSchedule ,
              let selectedEmoji,
              let selectedColor else { return }
        
        let newTracker = Tracker(id: UUID(), name: text, colorHex: selectedColor, emoji: selectedEmoji, schedule: selectedSchedule)
        addTracker(tracker: newTracker, toCategory: selectedCategory ?? "")
        
        dismiss(animated: true)
    }
    
    @objc
    private func dismissButtonDidTap() {
        dismiss(animated: true)
    }
}

// MARK: - Extensions
extension CreatingViewController: UITableViewDelegate, UITableViewDataSource {
    
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
        let mainText = indexPath.row == 0 ? NSLocalizedString("creatingView.categoryTitle", comment: "") : NSLocalizedString("creatingView.scheduleTitle", comment: "")
        let subText = indexPath.row == 0 ? selectedCategory : selectedSchedule?.toString()
        cell.configure(mainText: mainText, subText: subText)
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            tableView.deselectRow(at: indexPath, animated: false)
            
            let selectCategoryViewController = SelectCategoryViewController(delegateTrackersView: delegate, delegateCreatingView: self)
            present(selectCategoryViewController, animated: true)
            
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
            let selectScheduleViewController = SelectScheduleViewController()
            selectScheduleViewController.delegate = self
            present(selectScheduleViewController, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}

extension CreatingViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        section == 0 ? emojiList.count : colorList.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CreatingEmojiColorCell.identifier, for: indexPath) as? CreatingEmojiColorCell
        else { return UICollectionViewCell() }
        
        let label = indexPath.section == 0 ? emojiList[indexPath.row] : nil
        let color = indexPath.section == 1 ? UIColor(hex: colorList[indexPath.row]) : nil
        cell.configure(labelText: label,
                       backGroundColor: color)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 0, bottom: section == 0 ? 40 : 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        guard let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: CreatingEmojiColorHeaderCell.identifier,
            for: indexPath
        ) as? CreatingEmojiColorHeaderCell else {
            return UICollectionReusableView()
        }
        
        header.titleLabel.text = indexPath.section == 0 ? NSLocalizedString("creatingView.emojiTitle", comment: "") : NSLocalizedString("creatingView.colorTitle", comment: "")
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 58)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems?.filter({ $0.section == indexPath.section && $0.row != indexPath.row }) {
            selectedIndexPaths.forEach { collectionView.deselectItem(at: $0, animated: true)}
        }
        
        if indexPath.section == 0 {
            selectedEmoji = emojiList[indexPath.row]
        } else {
            selectedColor = colorList[indexPath.row]
        }
        
        enableButtonWithCond()
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            selectedEmoji = nil
        } else {
            selectedColor = nil
        }
        disableButton()
    }
}




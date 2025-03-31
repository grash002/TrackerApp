import UIKit

final class TrackersViewController: UIViewController, TrackersViewControllerProtocol {
    
    // MARK: - Public Properties
    
    var categories: [TrackerCategory] {
        trackerCategoryStore.categories ?? []
    }
    var filterState = FilterState.all
    
    // MARK: - Private Properties
    private let analyticsService = AnalyticsService()
    private let formatter = DateFormatter()
    private let datePicker = UIDatePicker()
    private let trackerCategoryStore = TrackerCategoryStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private var selectedCategories: [TrackerCategory] = []
    lazy private var completedTrackers: [CompletedTrackers] = {
        trackerRecordStore.fetchTrackerRecords()
    }()
    private var pickedDate: Date {
        calendar.startOfDay(for: datePicker.date).addingTimeInterval(TimeInterval(calendar.timeZone.secondsFromGMT()))
    }
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.allowsSelection = true
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        collectionView.register(TrackerHeaderCell.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: TrackerHeaderCell.identifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
        collectionView.reloadData()
        return collectionView
    }()
    private var calendar = Calendar.current
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .label
        titleLabel.text = NSLocalizedString("trackersView.title", comment: "")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = NSLocalizedString("trackersView.searchBar.placeHolder", comment: "")
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        searchBar.searchTextField.addTarget(self, action: #selector(searchTextDidChanged), for: .editingChanged)
        return searchBar
    }()
    
    private lazy var stackViewTopNav: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [ titleLabel, searchBar ])
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var noTrackerConstraints: [NSLayoutConstraint] = [
        imageNoTrackers.heightAnchor.constraint(equalToConstant: 80),
        imageNoTrackers.widthAnchor.constraint(equalToConstant: 80),
        stackViewNoTrackers.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        stackViewNoTrackers.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ]
    
    private lazy var trackerConstraints: [NSLayoutConstraint] = [
        collectionView.topAnchor.constraint(equalTo: stackViewTopNav.bottomAnchor, constant: 24),
        collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
        collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
        collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
    ]
    
    private lazy var imageNoTrackers: UIImageView = {
        let image = UIImageView(image: UIImage(named: "NoTrackers"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var labelNoTrackers: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("trackersView.emptyState.title", comment: "")
        label.textColor = .label
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var stackViewNoTrackers: UIStackView = {
        let stackView = UIStackView(arrangedSubviews:
                                        [imageNoTrackers,
                                         labelNoTrackers])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        return stackView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("trackersView.filterButton", comment: ""), for: .normal)
        button.backgroundColor = UIColor(hex: "#3772E7")
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonDidTap), for: .touchUpInside)
        view.addSubview(button)
        return button
    }()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        trackerCategoryStore.delegate = self
        trackerRecordStore.delegate = self
        
        dateChanged(datePicker)
        setView()
        
        analyticsService.report(event: AnalyticEvents.open.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: AnalyticEvents.close.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - Public Methods
    func refreshTrackersConstraints() {
        selectedCategories = categories
        
        modifyByFilter()
        
        if selectedCategories.count > 0 {
            for i in 0...selectedCategories.count - 1 {
                if selectedCategories[i].trackers.count > 0 {
                    for j in (0...selectedCategories[i].trackers.count - 1).reversed() {
                        if !selectedCategories[i].trackers[j].schedule.isSelected(selectedDate: pickedDate) {
                            selectedCategories[i].trackers.remove(at: j) }
                    }
                }
            }
            for k in (0...selectedCategories.count - 1).reversed() {
                if selectedCategories[k].trackers.isEmpty {
                    selectedCategories.remove(at: k)
                }
            }
        }
        
        setStackViewNoTrackers()
        setPinnedTrackers()
       
        collectionView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = .systemBackground
        
        let navigationBar = UINavigationBar()
        let navigationItem = UINavigationItem()
        
        let addButton =
        UIBarButtonItem(image: UIImage(named: "AddTracker"),
                        style: .plain,
                        target: self,
                        action: #selector(addButtonDidTap))
        addButton.tintColor = .label
        
        navigationItem.leftBarButtonItem = addButton
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self,
                             action: #selector(dateChanged(_:)),
                             for: .valueChanged)
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.titleView?.tintColor = .label
        navigationItem.rightBarButtonItem = datePickerItem
        
        navigationBar.items = [navigationItem]
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.barTintColor = .invertedLabel
        navigationBar.isTranslucent = false
        
        navigationBar.shadowImage = UIImage()
        view.addSubview(navigationBar)
        
        NSLayoutConstraint.activate([
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114)
        ])
        collectionView.contentInset.bottom = 60
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            stackViewTopNav.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            stackViewTopNav.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackViewTopNav.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
        ])
        
        setPinnedTrackers()
        refreshTrackersConstraints()
    }
    
    private func modifyByFilter() {
        switch filterState {
        case .all:
            let _ = 0
        case .onlyToDay:
            datePicker.date = Date()
        case .completed:
            
            selectedCategories = selectedCategories.compactMap({ category in
                var mutatingCategory = category
                
                var trackers = category.trackers.compactMap({ tracker in
                    if let indexTracker = completedTrackers.firstIndex(where: {$0.trackerId == tracker.id }),
                       completedTrackers[indexTracker].dates.contains(pickedDate) {
                        return tracker
                    }
                    return nil
                })
                mutatingCategory.trackers = trackers
                return mutatingCategory.trackers.isEmpty ? nil : mutatingCategory
            })
            
        case .uncompleted:
            selectedCategories = selectedCategories.compactMap({ category in
                var mutatingCategory = category
                
                var trackers: [Tracker] = category.trackers.compactMap({ tracker in
                    if let indexTracker = completedTrackers.firstIndex(where: {$0.trackerId == tracker.id }),
                       completedTrackers[indexTracker].dates.contains(pickedDate) {
                        return nil
                    }
                    return tracker
                })
                mutatingCategory.trackers = trackers
                return mutatingCategory.trackers.isEmpty ? nil : mutatingCategory
            })
        }
    }
    
    private func setStackViewNoTrackers() {
        var flagCategories = true
        selectedCategories.forEach({ flagCategories = flagCategories && $0.trackers.isEmpty })
        var emptyFlag = true
        
        if selectedCategories.isEmpty || flagCategories {
            categories.forEach({ emptyFlag = emptyFlag && $0.trackers.isEmpty })
            
            imageNoTrackers.image = emptyFlag ? UIImage(named: "NoTrackers") : UIImage(named: "NoFound")
            labelNoTrackers.text = emptyFlag ?  NSLocalizedString("trackersView.emptyState.title", comment: "") : NSLocalizedString("trackersView.NotFound.title", comment: "")
            
            NSLayoutConstraint.activate(noTrackerConstraints)
            NSLayoutConstraint.deactivate(trackerConstraints)
            collectionView.isHidden = true
            stackViewNoTrackers.isHidden = false
            
            if emptyFlag {
                filterButton.isHidden = true
            }
        }
        else {
            NSLayoutConstraint.activate(trackerConstraints)
            NSLayoutConstraint.deactivate(noTrackerConstraints)
            collectionView.isHidden = false
            stackViewNoTrackers.isHidden = true
            filterButton.isHidden = false
        }
    }
    
    private func setPinnedTrackers() {
        var pinnedTrackers: [Tracker] = []
        
        selectedCategories = selectedCategories.compactMap { category in
            var mutableCategory = category
            let (pinned, unpinned) = category.trackers.partitioned { $0.pinnedFlag }
            mutableCategory.trackers = unpinned
            pinnedTrackers += pinned
            return mutableCategory.trackers.isEmpty ? nil : mutableCategory
        }
        if !pinnedTrackers.isEmpty {
            selectedCategories.insert(TrackerCategory(id: UUID(), title: "Закрепленные", trackers: pinnedTrackers), at: 0)
        }
    }
    
    @objc
    private func filterButtonDidTap() {
        let view = FiltersViewController()
        view.delegate = self
        
        analyticsService.report(event: AnalyticEvents.click.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self), AnalyticField.item.rawValue: AnalyticItem.filter.rawValue])
        self.present(view, animated: true)
    }
    
    @objc
    private func addButtonDidTap() {
        let view = TrackerCreatingViewController()
        view.delegate = self
        
        analyticsService.report(event: AnalyticEvents.click.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self), AnalyticField.item.rawValue: AnalyticItem.add_track.rawValue])
        present(view, animated: true)
    }
    
    @objc
    private func dateChanged(_ sender: UIDatePicker) {
        if filterState == .onlyToDay {
            filterState = .all
        }
        refreshTrackersConstraints()
    }
    
    @objc
    private func searchTextDidChanged(_ searchBar: UISearchBar) {
        refreshTrackersConstraints()
        
        guard let searchText = searchBar.text, !searchText.isEmpty else {
            return
         }
        
        selectedCategories = selectedCategories.compactMap { category in
             let filteredTrackers = category.trackers.filter {
                 $0.name.lowercased().contains(searchText.lowercased())
             }

             guard !filteredTrackers.isEmpty else { return nil }

             return TrackerCategory(
                 id: category.id,
                 title: category.title,
                 trackers: filteredTrackers
             )
         }
        setStackViewNoTrackers()
    }
}

// MARK: - Extensions
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedCategories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var num = 0
        selectedCategories.forEach({ num += $0.trackers.isEmpty ? 0 : 1})
        return num
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        let item = selectedCategories[indexPath.section].trackers[indexPath.item]
        
        var isDidTap = false
        var countDays = 0
        
        if let indexTracker = completedTrackers.firstIndex(where: {$0.trackerId == item.id }) {
            isDidTap = completedTrackers[indexTracker].dates.contains(pickedDate)
            countDays = completedTrackers[indexTracker].dates.count
        }
        
        let isDisableAddButton = pickedDate > calendar.startOfDay(for: Date()).addingTimeInterval(TimeInterval(calendar.timeZone.secondsFromGMT()))
        
        let onSaveCountDays = {[weak self] addButtonDidTapFlag in
            guard let self else { return }
            NotificationCenter.default.post(name: .didTapCompleteButton, object: nil)
            self.analyticsService.report(event: AnalyticEvents.click.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self), AnalyticField.item.rawValue: AnalyticItem.track.rawValue])
            
            if !addButtonDidTapFlag {
                trackerRecordStore.createTrackerRecord(trackerId: item.id, trackingDate: pickedDate)
            } else {
                trackerRecordStore.deleteTrackerRecord(trackerId: item.id, trackingDate: pickedDate)
            }
            self.collectionView.reloadData()
        }
        
        let trackerId = item.id
        let categoryId = selectedCategories[indexPath.section].id
        let categoryName = categories.filter({ $0.trackers.contains(where: {$0.id == item.id}) }).first?.title ?? ""
        
        let onTapMenuPin = { [weak self] in
            self?.trackerCategoryStore.togglePinnedTracker(id: trackerId)
            self?.refreshTrackersConstraints()
        }
        let onTapMenuEdit = { [weak self] in
            
            self?.analyticsService.report(event: AnalyticEvents.click.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self), AnalyticField.item.rawValue: AnalyticItem.edit.rawValue])
            
            let editCreatingViewController = EditTrackerViewController(tracker: item, categoryName: categoryName, countDays: countDays)
            editCreatingViewController.delegate = self
            self?.present(editCreatingViewController,
                              animated: true)
        }
        let onTapMenuDelete = { [weak self] in
            
            self?.analyticsService.report(event: AnalyticEvents.click.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self), AnalyticField.item.rawValue: AnalyticItem.delete.rawValue])
            
            let alert = UIAlertController(title: "",
                                          message: "Уверены что хотите удалить трекер?",
                                          preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
                self?.trackerCategoryStore.deleteTrackersCategory(id: trackerId)
                self?.trackerCategoryStore.removeTrackerFromCore(id: trackerId)
                self?.refreshTrackersConstraints()
            }
            let cancelAction = UIAlertAction(title: "Отменить", style: .cancel)
            alert.addAction(deleteAction)
            alert.addAction(cancelAction)
            self?.present(alert, animated: true)
        }
        
        cell.configure(nameTracker: item.name,
                       emoji: item.emoji,
                       color: UIColor(hex: item.colorHex),
                       isDidTap: isDidTap,
                       count: countDays,
                       isDisableAddButton: isDisableAddButton,
                       pinnedFlag: item.pinnedFlag,
                       onSaveCountDays: onSaveCountDays,
                       onTapMenuPin: onTapMenuPin,
                       onTapMenuEdit: onTapMenuEdit,
                       onTapMenuDelete: onTapMenuDelete
        )
        return cell
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalHorizontalInsets = 16 + 16
        let interItemSpacing: CGFloat = 9
        let availableWidth = collectionView.bounds.width - CGFloat(totalHorizontalInsets) - interItemSpacing
        let itemWidth = availableWidth / 2
        return CGSize(width: itemWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        9
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                           withReuseIdentifier: TrackerHeaderCell.identifier,
                                                                           for: indexPath) as? TrackerHeaderCell
        else { return UICollectionReusableView() }
        header.titleLabel.text = selectedCategories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}

extension TrackersViewController: TrackerCategoryStoreDelegate {
    func storeTrackerCategory() {
        refreshTrackersConstraints()
    }
}

extension TrackersViewController: TrackerRecordStoreDelegate {
    func storeTrackerRecord() {
        completedTrackers = trackerRecordStore.fetchTrackerRecords()
    }
}

extension TrackersViewController: FiltersViewControllerDelegate {
    func setFilterState(_ state: FilterState) {
        filterState = state
        refreshTrackersConstraints()
    }
}

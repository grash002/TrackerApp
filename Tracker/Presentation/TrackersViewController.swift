import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Public Properties
    let formatter = DateFormatter()
    let datePicker = UIDatePicker()
    var categories: [TrackerCategory] = []
    var selectedCategories: [TrackerCategory] = []
    var completedTrackers: [CompletedTrackers] = []
    var pickedDate: Date {
        calendar.startOfDay(for: datePicker.date).addingTimeInterval(TimeInterval(calendar.timeZone.secondsFromGMT()))
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 10
        
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
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
    
    // MARK: - Private Properties
    private var calendar = Calendar.current
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        return titleLabel
    }()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
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
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
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
    
    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Mock Data
        let mockSchedule = Schedule(days: [.monday])
        categories.append(TrackerCategory(title: "Домашний уют", trackers: [
            Tracker(id: UUID(), name: "Поливать растения", color: .green, emoji: "❤️", schedule: mockSchedule),
        ]))
        categories.append(TrackerCategory(title: "Радостные мелочи", trackers: [
            Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .orange, emoji: "😸", schedule: Schedule(days: [.friday])),
            Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: .red, emoji: "🌸", schedule: mockSchedule),
            Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: .magenta, emoji: "🌸", schedule: mockSchedule),
        ]))
        
        dateChanged(datePicker)
        setView()
    }
    
    //MARK: - Public Methods
    func refreshTrackersConstraints() {
        selectedCategories = categories
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
            
            var flagCategories = true
            selectedCategories.forEach({ flagCategories = flagCategories && $0.trackers.isEmpty })
            
            if (selectedCategories.isEmpty || flagCategories){
                NSLayoutConstraint.activate(noTrackerConstraints)
                NSLayoutConstraint.deactivate(trackerConstraints)
                collectionView.isHidden = true
                stackViewNoTrackers.isHidden = false
            }
            else {
                NSLayoutConstraint.activate(trackerConstraints)
                NSLayoutConstraint.deactivate(noTrackerConstraints)
                collectionView.isHidden = false
                stackViewNoTrackers.isHidden = true
            }
        collectionView.reloadData()
        }
    
    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = UIColor.white
        
        let navigationBar = UINavigationBar()
        let navigationItem = UINavigationItem()
        
        let addButton =
        UIBarButtonItem(image: UIImage(named: "AddTracker"),
                        style: .plain,
                        target: self,
                        action: #selector(addButtonDidTap))
        addButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = addButton
        
        
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.addTarget(self,
                             action: #selector(dateChanged(_:)),
                             for: .valueChanged)
        let datePickerItem = UIBarButtonItem(customView: datePicker)
        navigationItem.rightBarButtonItem = datePickerItem
        
        navigationBar.items = [navigationItem]
        
        navigationBar.translatesAutoresizingMaskIntoConstraints = false
        navigationBar.barTintColor = .white
        navigationBar.shadowImage = UIImage()
        view.addSubview(navigationBar)
        
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            stackViewTopNav.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            stackViewTopNav.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackViewTopNav.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
        ])
        
        refreshTrackersConstraints()
        
    }
    
    @objc
    private func addButtonDidTap() {
        let view = TrackerCreatingViewController()
        view.delegate = self
        present(view, animated: true)
    }
    
    @objc
    private func dateChanged(_ sender: UIDatePicker) {
        refreshTrackersConstraints()
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
        var coundDays = 0
        
        if let indexTracker = completedTrackers.firstIndex(where: {$0.trackedId == item.id }) {
            isDidTap = completedTrackers[indexTracker].dates.contains(pickedDate)
            coundDays = completedTrackers[indexTracker].dates.count
        }
        
        let isDisableAddButton = pickedDate > calendar.startOfDay(for: Date()).addingTimeInterval(TimeInterval(calendar.timeZone.secondsFromGMT()))
       
        
        cell.configure(nameTracker: item.name,
                       emoji: item.emoji,
                       color: item.color,
                       isDidTap: isDidTap,
                       count: coundDays,
                       isDisableAddButton: isDisableAddButton)
        {[weak self] addButtonDidTapFlag in
            guard let self else { return }
            if !addButtonDidTapFlag {
                if let index = self.completedTrackers.firstIndex(where: {$0.trackedId == item.id}),
                   !self.completedTrackers[index].dates.contains(where: {$0 == self.pickedDate}){
                    self.completedTrackers[index].dates.append(self.pickedDate)
                } else {
                    self.completedTrackers.append(CompletedTrackers(trackedId: item.id, dates: [self.pickedDate]))
                }
            } else {
                if let indexTracker = self.completedTrackers.firstIndex(where: {$0.trackedId == item.id}),
                   let indexDate = self.completedTrackers[indexTracker].dates.firstIndex(where: {$0 == self.pickedDate}){
                    self.completedTrackers[indexTracker].dates.remove(at: indexDate)
                }
            }
            self.collectionView.reloadData()
        }
        
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

import UIKit

final class TrackersViewController: UIViewController {
    
    // MARK: - Public Properties
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    let formatter = DateFormatter()
    
    // MARK: - Private Properties
    var collectionView: UICollectionView!

    // MARK: - Overrides Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Mock Data
        let mockSchedule = Schedule(days: [.monday])
        categories.append(TrackerCategory(title: "Домашний уют", trackers: [
            Tracker(id: UUID(), name: "Поливать растения", color: .green, emoji: "❤️", schedule: mockSchedule),
        ]))
        categories.append(TrackerCategory(title: "Радостные мелочи", trackers: [
            Tracker(id: UUID(), name: "Кошка заслонила камеру на созвоне", color: .orange, emoji: "😸", schedule: mockSchedule),
            Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: .red, emoji: "🌸", schedule: mockSchedule),
            Tracker(id: UUID(), name: "Бабушка прислала открытку в вотсапе", color: .magenta, emoji: "🌸", schedule: mockSchedule),
        ]))
        
        let layout = UICollectionViewFlowLayout()

        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.minimumInteritemSpacing = 9
        layout.minimumLineSpacing = 10 
        
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        setView()
        
        
    }
    
    // MARK: - IB Actions

    // MARK: - Public Methods

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
        
        
        let datePicker = UIDatePicker()
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
        
        let titleLabel = UILabel()
        titleLabel.text = "Трекеры"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        
        let stackViewTopNav = UIStackView(arrangedSubviews: [
            titleLabel,
            searchBar
                                                            ])
        
        stackViewTopNav.axis = .vertical
        stackViewTopNav.spacing = 7
        stackViewTopNav.alignment = .fill
        stackViewTopNav.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackViewTopNav)
        
        NSLayoutConstraint.activate([
            navigationBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navigationBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            navigationBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            stackViewTopNav.topAnchor.constraint(equalTo: navigationBar.bottomAnchor),
            stackViewTopNav.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackViewTopNav.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
        ])
        if categories.isEmpty {
            let imageNoTrackers = UIImageView(image: UIImage(named: "NoTrackers"))
            imageNoTrackers.translatesAutoresizingMaskIntoConstraints = false
            
            
            let labelNoTrackers = UILabel()
            labelNoTrackers.text = "Что будем отслеживать?"
            labelNoTrackers.font = UIFont.systemFont(ofSize: 12)
            
            let stackView = UIStackView(arrangedSubviews:
                                            [imageNoTrackers,
                                             labelNoTrackers])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 8
            
            view.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                imageNoTrackers.heightAnchor.constraint(equalToConstant: 80),
                imageNoTrackers.widthAnchor.constraint(equalToConstant: 80),
                stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            ])
        }
        else {
            collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
            collectionView.register(TrackerHeaderCell.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: TrackerHeaderCell.identifier)
            collectionView.translatesAutoresizingMaskIntoConstraints = false
            collectionView.reloadData()
            view.addSubview(collectionView)
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: stackViewTopNav.bottomAnchor, constant: 24),
                collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
                collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
        }
    }
    
    @objc
    func addButtonDidTap() {
        print("AddButton did tap")
        let view = TrackerCreatingViewController()
        view.delegate = self
        present(view, animated: true)
    }
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        formatter.dateStyle = .short
        print("Selected date: \(formatter.string(from: sender.date))")
    }
}

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate  {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        let item = categories[indexPath.section].trackers[indexPath.item]
        
        cell.emojiLabel.text = item.emoji
        cell.titleLabel.text = item.name
        cell.viewCardTracker.backgroundColor = item.color
        cell.addButton.backgroundColor = item.color
        
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
        header.titleLabel.text = categories[indexPath.section].title
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
}

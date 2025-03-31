import UIKit

final class SelectScheduleViewController: UIViewController {
    // MARK: - Public Properties
    var delegate: CreatingViewControllerProtocol?
    
    // MARK: - Private Properties
    private let tableViewSchedule = UITableView()
    private let createButton = UIButton(type: .custom)
    private let totalRows = 7
    private let weakDays = [NSLocalizedString("selectSchedule.Monday", comment: ""),
                            NSLocalizedString("selectSchedule.Tuesday", comment: ""),
                            NSLocalizedString("selectSchedule.Wednesday", comment: ""),
                            NSLocalizedString("selectSchedule.Thursday", comment: ""),
                            NSLocalizedString("selectSchedule.Friday", comment: ""),
                            NSLocalizedString("selectSchedule.Saturday", comment: ""),
                            NSLocalizedString("selectSchedule.Sunday", comment: "")]
    private var schedule = Schedule(days: [])
    private let analyticsService = AnalyticsService()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
        analyticsService.report(event: AnalyticEvents.open.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        analyticsService.report(event: AnalyticEvents.close.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("selectSchedule.title", comment: "")
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        tableViewSchedule.dataSource = self
        tableViewSchedule.delegate = self
        tableViewSchedule.register(ScheduleCell.self,
                                   forCellReuseIdentifier: ScheduleCell.identifier)
        tableViewSchedule.translatesAutoresizingMaskIntoConstraints = false
        tableViewSchedule.backgroundColor = .systemBackground
        tableViewSchedule.layer.cornerRadius = 16
        tableViewSchedule.tableFooterView = UIView()
        tableViewSchedule.separatorInset = UIEdgeInsets(top: 0,
                                                        left: 16,
                                                        bottom: 0,
                                                        right: 16)
        view.addSubview(tableViewSchedule)
        
        createButton.setTitle(NSLocalizedString("selectSchedule.createButton.Title", comment: ""), for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.backgroundColor = .label
        createButton.setTitleColor(.invertedLabel, for: .normal)
        createButton.addTarget(self,
                               action: #selector(createButtonDidTap),
                               for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableViewSchedule.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableViewSchedule.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            tableViewSchedule.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            tableViewSchedule.heightAnchor.constraint(equalToConstant: CGFloat(totalRows * 75)),
            tableViewSchedule.bottomAnchor.constraint(lessThanOrEqualTo: createButton.topAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
    }
    
    @objc
    private func createButtonDidTap(){
        delegate?.selectSchedule(schedule: schedule)
        self.dismiss(animated: true)
    }
}

// MARK: - Extension
extension SelectScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        totalRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleCell.identifier,
                                                       for: indexPath) as? ScheduleCell else { return UITableViewCell()}
        cell.backgroundColor = UIColor(named: "BackGroundFields")
        cell.selectionStyle = .none
        cell.configure(text: weakDays[indexPath.row], indexRow: indexPath.row) {[weak self] switcherIsOn, indexRow in
            guard let weekday = WeekDay(rawValue: indexRow) else { return }
            if switcherIsOn {
                self?.schedule.add(weekday: weekday)
            } else {
                if let removeIndex = self?.schedule.days.firstIndex(of: weekday) {
                    self?.schedule.days.remove(at: removeIndex)
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        
        if indexPath.row == totalRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
}

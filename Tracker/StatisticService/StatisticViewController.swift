import UIKit

// MARK: - Private Methods
final class StatisticViewController: UIViewController {
    
    // MARK: - Private Properties
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.textColor = .label
        titleLabel.text = NSLocalizedString("statisticView.title", comment: "")
        titleLabel.font = UIFont.boldSystemFont(ofSize: 34)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        return titleLabel
    }()
    private let tableView = UITableView()
    private let statisticService = StatisticService.shared
    private var data: [String: Int] {
        statisticService.calculateStatistics()
    }
    private var keys: [String] {
        data.map { $0.key }
    }
    
    // MARK: - Initializers
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didTapCompleteButton, object: nil)
    }
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        view.backgroundColor = .systemBackground
        setView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCompleteButtonTap),
            name: .didTapCompleteButton,
            object: nil
        )
        
        AnalyticsService.report(event: AnalyticEvents.open.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AnalyticsService.report(event: AnalyticEvents.close.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    // MARK: - Private Methods
    private func setView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(StatisticCell.self,
                                     forCellReuseIdentifier: StatisticCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .white
        tableView.layer.cornerRadius = 16
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.separatorInset = UIEdgeInsets(top: 6,
                                                left: 0,
                                                bottom: 6,
                                                right: 0)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 44),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    @objc
    private func handleCompleteButtonTap() {
        tableView.reloadData()
    }
}

// MARK: - Extensions
extension StatisticViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: StatisticCell.identifier,
                                                    for: indexPath) as? StatisticCell{
            cell.configure(topLabel: NSLocalizedString(String(describing: data[keys[indexPath.row]] ?? 0), comment: ""),
                           bottomLabel: NSLocalizedString(keys[indexPath.row], comment: ""))
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        102
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }
}

import UIKit

// MARK: - Private Methods
final class FiltersViewController: UIViewController {
    
    // MARK: - Private Properties
    weak var delegate: FiltersViewControllerDelegate?
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("filterCategory.title", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()
    lazy private var tableViewCategories = UITableView()
    private let filterStates = ["Все трекеры",
                                "Трекеры на сегодня",
                                "Завершенные",
                                "Не завершенные" ]
    private var selectedRow: Int?
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        setView()
        AnalyticsService.report(event: AnalyticEvents.open.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AnalyticsService.report(event: AnalyticEvents.close.rawValue , 
                                params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        selectTableRow()
    }
    
    private func setView() {
        view.backgroundColor = .systemBackground
        
        tableViewCategories.dataSource = self
        tableViewCategories.delegate = self
        tableViewCategories.register(UITableViewCell.self,
                                     forCellReuseIdentifier: "cell")
        tableViewCategories.translatesAutoresizingMaskIntoConstraints = false
        tableViewCategories.backgroundColor = .white
        tableViewCategories.layer.cornerRadius = 16
        tableViewCategories.tableFooterView = UIView()
        tableViewCategories.separatorInset = UIEdgeInsets(top: 0,
                                                          left: 16,
                                                          bottom: 0,
                                                          right: 16)
        view.addSubview(tableViewCategories)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            tableViewCategories.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            tableViewCategories.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
            tableViewCategories.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
            tableViewCategories.heightAnchor.constraint(equalToConstant: 75 * 4),
            tableViewCategories.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
    }
    private func selectTableRow() {
        guard let filterState = delegate?.filterState
         else { return }
        let index = filterState.rawValue
        let selectRow = tableViewCategories.cellForRow(at: IndexPath(row: index, section: 0) )
        selectRow?.accessoryType = .checkmark
        selectedRow = index
    }
    
}

//MARK: - Extensions
extension FiltersViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        filterStates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                                 for: indexPath)
        cell.backgroundColor = UIColor { trait in
            trait.userInterfaceStyle == .dark
                ? UIColor(white: 0.15, alpha: 1)
                : UIColor(white: 0.95, alpha: 1)
        }
        cell.selectionStyle = .none
        cell.textLabel?.text = filterStates[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let selectedRow {
            tableView.cellForRow(at: IndexPath(row: selectedRow, section: 0))?.accessoryType = .none
        }
        
        let selectRow = tableView.cellForRow(at: indexPath)
        selectRow?.accessoryType = .checkmark
        delegate?.setFilterState(FilterState(rawValue: indexPath.row) ?? FilterState.all)
        dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectRow = tableView.cellForRow(at: indexPath)
        deselectRow?.accessoryType = .none
    }
}

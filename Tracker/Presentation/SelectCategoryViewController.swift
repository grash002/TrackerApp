import UIKit

final class SelectCategoryViewController: UIViewController {

    // MARK: - Public Properties
    var delegateTrackersView: TrackersViewController?
    var delegateHabitCreating: HabitCreatingViewController?
    
    // MARK: - Private Properties
    private let tableViewCategories = UITableView()
    private var tableViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    // MARK: - Public Methods
    func addCategory(categoryTitle: String) {
        delegateHabitCreating?.addCategory(toCategory: categoryTitle)
        
        let newCategoryIndex = IndexPath(row: (delegateTrackersView?.categories.count ?? 1) - 1, section: 0)
        
        tableViewCategories.performBatchUpdates({
            tableViewCategories.insertRows(at: [newCategoryIndex], with: .automatic)
        })
        
        tableViewHeightConstraint?.constant = CGFloat((delegateTrackersView?.categories.count ?? 0) * 75)

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        tableViewCategories.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    // MARK: - Private Methods
    private func setView() {
        guard let delegateTrackersView else { return }
        
        view.backgroundColor = .white
        
        let titlelLabel = UILabel()
        titlelLabel.text = "Категория"
        titlelLabel.textAlignment = .center
        titlelLabel.font = UIFont.systemFont(ofSize: 16)
        titlelLabel.textColor = .black
        titlelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titlelLabel)
        
        let createButton = UIButton(type: .custom)
        createButton.setTitle("Добавить категорию", for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.tintColor = .white
        createButton.backgroundColor = .black
        createButton.addTarget(self,
                               action: #selector(createButtonDidTap),
                               for: .touchUpInside)
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        if delegateTrackersView.categories.count == 0 {
            let imageNoCategories = UIImageView(image: UIImage(named: "NoTrackers"))
            imageNoCategories.translatesAutoresizingMaskIntoConstraints = false
            
            
            let labelNoTrackers = UILabel()
            labelNoTrackers.text = "Привычки и события можно\n объединить по смыслу"
            labelNoTrackers.font = UIFont.systemFont(ofSize: 12)
            labelNoTrackers.textAlignment = .center
            labelNoTrackers.numberOfLines = 0
            labelNoTrackers.lineBreakMode = .byWordWrapping
            
            let stackView = UIStackView(arrangedSubviews:
                                            [imageNoCategories,
                                             labelNoTrackers])
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            stackView.axis = .vertical
            stackView.alignment = .center
            stackView.spacing = 8
            
            view.addSubview(stackView)
            
            NSLayoutConstraint.activate([
                imageNoCategories.heightAnchor.constraint(equalToConstant: 80),
                imageNoCategories.widthAnchor.constraint(equalToConstant: 80),
                stackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                stackView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                

            ])
        } else {
            tableViewHeightConstraint = tableViewCategories.heightAnchor.constraint(equalToConstant: CGFloat(delegateTrackersView.categories.count * 75))
            
            guard let tableViewHeightConstraint else { return }
            
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
                tableViewCategories.topAnchor.constraint(equalTo: titlelLabel.bottomAnchor, constant: 24),
                tableViewCategories.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
                tableViewCategories.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
                tableViewHeightConstraint,
                tableViewCategories.bottomAnchor.constraint(lessThanOrEqualTo: createButton.topAnchor)
            ])
        }
        
        NSLayoutConstraint.activate([
            titlelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titlelLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titlelLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
            ])
    }
    
    @objc
    private func createButtonDidTap(){
        let categoryCreatingViewController = CategoryCreatingViewController()
        categoryCreatingViewController.delegate = self
        self.present(categoryCreatingViewController, animated: true)
    }
}

    //MARK: - Extensions
extension SelectCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        delegateTrackersView?.categories.count ?? 0
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell",
                                      for: indexPath)
        cell.backgroundColor = UIColor(named: "BackGroundFields")
        cell.selectionStyle = .none
        cell.textLabel?.text = delegateTrackersView?.categories[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        guard let delegateTrackersView = delegateTrackersView else { return }
        let totalRows = delegateTrackersView.categories.count

        if indexPath.row == totalRows - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectRow = tableView.cellForRow(at: indexPath)
        selectRow?.accessoryType = .checkmark
        delegateHabitCreating?.selectCategory(categoryTitle: delegateTrackersView?.categories[indexPath.row].title ?? "")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectRow = tableView.cellForRow(at: indexPath)
        deselectRow?.accessoryType = .none
    }
}

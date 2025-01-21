import UIKit

final class SelectCategoryViewController: UIViewController {

    // MARK: - Public Properties
    weak var delegateTrackersView: TrackersViewController?
    weak var delegateHabitCreating: HabitCreatingViewController?
    
    // MARK: - Private Properties
    private let tableViewCategories = UITableView()
    lazy private var tableViewHeightConstraint: NSLayoutConstraint = {
        tableViewCategories.heightAnchor.constraint(equalToConstant: CGFloat((delegateTrackersView?.categories.count ?? 0) * 75))
    }()
    
    lazy private var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Добавить категорию", for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.tintColor = .white
        button.backgroundColor = .black
        button.addTarget(self,
                               action: #selector(createButtonDidTap),
                               for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }()
    
    lazy private var titlelLabel: UILabel = {
        let label = UILabel()
        label.text = "Категория"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(label)
        return label
    }()
    
    lazy private var imageNoCategories: UIImageView = {
        let image = UIImageView(image: UIImage(named: "NoTrackers"))
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    lazy private var stackViewNoCategories: UIStackView = {
        let stackView = UIStackView(arrangedSubviews:[self.imageNoCategories,
                                                      self.labelNoTrackers])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        self.view.addSubview(stackView)
        return stackView
    }()
    
    lazy private var labelNoTrackers = {
        let label = UILabel()
        label.text = "Привычки и события можно\n объединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    lazy private var noCategoryConstr: [NSLayoutConstraint] = [
        imageNoCategories.heightAnchor.constraint(equalToConstant: 80),
        imageNoCategories.widthAnchor.constraint(equalToConstant: 80),
        stackViewNoCategories.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        stackViewNoCategories.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
    ]
    
    lazy private var categoryConstr: [NSLayoutConstraint] = {[
        tableViewCategories.topAnchor.constraint(equalTo: titlelLabel.bottomAnchor, constant: 24),
        tableViewCategories.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        tableViewCategories.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
        tableViewHeightConstraint,
        tableViewCategories.bottomAnchor.constraint(lessThanOrEqualTo: createButton.topAnchor)
    ]}()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }
    
    // MARK: - Public Methods
    func addCategory(categoryTitle: String) {
        delegateHabitCreating?.addCategory(toCategory: categoryTitle)
        refreshConstraints()
//        let newCategoryIndex = IndexPath(row: (delegateTrackersView?.categories.count ?? 1) - 1, section: 0)
        
        tableViewCategories.reloadData()
        
//        tableViewCategories.performBatchUpdates({
//            tableViewCategories.insertRows(at: [newCategoryIndex], with: .automatic)
//        })
        
        tableViewHeightConstraint.constant = CGFloat((delegateTrackersView?.categories.count ?? 0) * 75)

        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        tableViewCategories.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func refreshConstraints() {       
    if delegateTrackersView?.categories.count == 0 {
        tableViewCategories.isHidden = true
        stackViewNoCategories.isHidden = false
        NSLayoutConstraint.activate(noCategoryConstr)
        NSLayoutConstraint.deactivate(categoryConstr)
        
    } else {
        tableViewCategories.isHidden = false
        stackViewNoCategories.isHidden = true
        
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
        
        NSLayoutConstraint.activate(categoryConstr)
        NSLayoutConstraint.deactivate(noCategoryConstr)
    }
    }
    
    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = .white
        refreshConstraints()
        
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

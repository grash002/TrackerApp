import UIKit

final class SelectCategoryViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegateCreatingView: CreatingViewControllerProtocol?
    weak var delegateTrackersView: TrackersViewControllerProtocol?
    
    // MARK: - Private Properties
    private lazy var viewModel = SelectCategoryViewModel()
    
    private let tableViewCategories = UITableView()
    lazy private var tableViewHeightConstraint: NSLayoutConstraint = {
        tableViewCategories.heightAnchor.constraint(equalToConstant: CGFloat(viewModel.categories.count * 75))
    }()
    
    lazy private var createButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("selectCategory.button.title", comment: ""), for: .normal)
        button.layer.cornerRadius = 16
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.invertedLabel, for: .normal)
        button.backgroundColor = .label
        button.addTarget(self,
                         action: #selector(createButtonDidTap),
                         for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }()
    
    lazy private var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("selectCategory.title", comment: "")
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
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
        label.text = NSLocalizedString("selectCategory.emptyState.title", comment: "")
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
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
        tableViewCategories.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
        tableViewCategories.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -24),
        tableViewCategories.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 24),
        tableViewHeightConstraint,
        tableViewCategories.bottomAnchor.constraint(lessThanOrEqualTo: createButton.topAnchor)
    ]}()
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.onCreateCategoryRequested = { [weak self] in
            let categoryCreatingVC = CategoryCreatingViewController()
            categoryCreatingVC.delegate = self
            self?.present(categoryCreatingVC, animated: true)
        }
        
        viewModel.onAddCategoryRequested = { [weak delegateCreatingView] title in
            delegateCreatingView?.addCategory(toCategory: title)
        }
        
        viewModel.onGetCategoriesRequested = { [weak delegateTrackersView] in
            delegateTrackersView?.categories
        }
        
        viewModel.onGetCategoriesRequested = { [weak delegateTrackersView] in
            delegateTrackersView?.categories
        }
        
        viewModel.onSelectCategoryRequested = { [weak delegateCreatingView] title in
            delegateCreatingView?.selectCategory(categoryTitle: title)
        }
        
        setView()
    }
    
    init(delegateTrackersView: TrackersViewControllerProtocol?, delegateCreatingView: CreatingViewControllerProtocol?) {
        self.delegateTrackersView = delegateTrackersView
        self.delegateCreatingView = delegateCreatingView
        super.init(nibName: nil, bundle: nil)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func addCategory(categoryTitle: String) {
        viewModel.addCategory(title: categoryTitle)
        refreshConstraints()
        tableViewCategories.reloadData()
        tableViewHeightConstraint.constant = CGFloat(viewModel.categories.count * 75)
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
        
        tableViewCategories.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    func refreshConstraints() {
        if viewModel.numberOfCategories() == 0 {
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
        view.backgroundColor = .systemBackground
        refreshConstraints()
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func createButtonDidTap(){
        viewModel.createButtonDidTap(controller: self)
        tableViewCategories.reloadData()
    }
}

//MARK: - Extensions
extension SelectCategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories()
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
        cell.textLabel?.text = viewModel.categories[indexPath.row].title
        cell.textLabel?.font = UIFont.systemFont(ofSize: 17)
        cell.textLabel?.textColor = .label
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectRow = tableView.cellForRow(at: indexPath)
        selectRow?.accessoryType = .checkmark
        viewModel.selectCategory(index: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deselectRow = tableView.cellForRow(at: indexPath)
        deselectRow?.accessoryType = .none
    }
}

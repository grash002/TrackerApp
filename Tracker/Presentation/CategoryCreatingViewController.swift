import UIKit

final class CategoryCreatingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Public Properties
    weak var delegate: SelectCategoryViewController?
    
    // MARK: - Private Properties
    private let textField = UITextField()
    private let createButton = UIButton(type: .custom)
    private let titleLabel = UILabel()
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = .systemBackground
        
        titleLabel.text = NSLocalizedString("categoryCreating.title", comment: "")
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        
        createButton.setTitle(NSLocalizedString("categoryCreating.button.title", comment: ""), for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.invertedLabel, for: .normal)
        createButton.addTarget(self,
                               action: #selector(createButtonDidTap),
                               for: .touchUpInside)
        createButton.isEnabled = false
        createButton.backgroundColor = .gray
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        textField.placeholder = NSLocalizedString("categoryCreating.textField.placeHolder", comment: "")
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
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 75),
            
            createButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            createButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc
    private func createButtonDidTap() {
        if let delegate,
           let newCategory = textField.text {
            delegate.addCategory(categoryTitle: newCategory)
            self.dismiss(animated: true)
        }
    }
    
    @objc
    private func textFieldDidChange() {
        if let text = textField.text, !text.isEmpty {
            createButton.isEnabled = true
            createButton.backgroundColor = .label
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
        }
    }
}


import UIKit

final class CategoryCreatingViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Public Properties
    var delegate: SelectCategoryViewController?
    
    // MARK: - Private Properties
    private let textField = UITextField()
    private let createButton = UIButton(type: .custom)
    private let titlelLabel = UILabel()

    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()
    }

    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = .white
        
        titlelLabel.text = "Новая категория"
        titlelLabel.textAlignment = .center
        titlelLabel.font = UIFont.systemFont(ofSize: 16)
        titlelLabel.textColor = .black
        titlelLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titlelLabel)
        

        createButton.setTitle("Готово", for: .normal)
        createButton.layer.cornerRadius = 16
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.tintColor = .white
        createButton.addTarget(self,
                               action: #selector(createButtonDidTap),
                               for: .touchUpInside)
        createButton.isEnabled = false
        createButton.backgroundColor = .gray
        createButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(createButton)
        
        textField.placeholder = "Введите название категории"
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
            titlelLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titlelLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titlelLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            textField.topAnchor.constraint(equalTo: titlelLabel.bottomAnchor, constant: 24),
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
            createButton.backgroundColor = .black
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = .gray
        }
    }
}


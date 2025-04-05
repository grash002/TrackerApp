import UIKit

final class TrackerCreatingViewController: UIViewController {
    
    // MARK: - Public Properties
    weak var delegate: TrackersViewController?
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setView()      
        AnalyticsService.report(event: AnalyticEvents.open.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        AnalyticsService.report(event: AnalyticEvents.close.rawValue , params: [AnalyticField.screen.rawValue: String(describing: self)])
    }
    
    // MARK: - Private Methods
    private func setView() {
        view.backgroundColor = .systemBackground
        
        let titleLabel = UILabel()
        titleLabel.text = NSLocalizedString("trackerCreatingView.title", comment: "")
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel)
        
        let habitCreateButton = UIButton(type: .custom)
        habitCreateButton.setTitle(NSLocalizedString("trackerCreatingView.habitTitle", comment: ""), for: .normal)
        habitCreateButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitCreateButton.setTitleColor(.invertedLabel, for: .normal)
        habitCreateButton.backgroundColor = .label
        habitCreateButton.layer.cornerRadius = 16
        habitCreateButton.addTarget(self,
                                    action: #selector(habitCreateButtonDidTap),
                                    for: .touchUpInside)
        habitCreateButton.translatesAutoresizingMaskIntoConstraints = false
        
        let irregularEventButton = UIButton(type: .custom)
        irregularEventButton.setTitle(NSLocalizedString("trackerCreatingView.irregularEventTitle", comment: ""), for: .normal)
        irregularEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularEventButton.setTitleColor(.invertedLabel, for: .normal)
        irregularEventButton.backgroundColor = .label
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.addTarget(self,
                                       action: #selector(irregularCreateButtonDidTap),
                                       for: .touchUpInside)
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        
        let stackButtons = UIStackView(arrangedSubviews: [
            habitCreateButton,
            irregularEventButton
        ])
        stackButtons.axis = .vertical
        stackButtons.translatesAutoresizingMaskIntoConstraints = false
        stackButtons.spacing = 16
        stackButtons.alignment = .fill
        view.addSubview(stackButtons)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            titleLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            stackButtons.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stackButtons.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            stackButtons.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackButtons.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            habitCreateButton.heightAnchor.constraint(equalToConstant: 60),
        ])
        
        
    }
    
    @objc
    private func habitCreateButtonDidTap() {
        self.dismiss(animated: true)
        let habitCreatingViewController = HabitCreatingViewController()
        habitCreatingViewController.delegate = delegate
        delegate?.present(habitCreatingViewController,
                          animated: true)
    }
    
    @objc
    private func irregularCreateButtonDidTap() {
        self.dismiss(animated: true)
        let irregularEventCreatingViewController = IrregularEventCreatingViewController()
        irregularEventCreatingViewController.delegate = delegate
        delegate?.present(irregularEventCreatingViewController,
                          animated: true)
    }
}



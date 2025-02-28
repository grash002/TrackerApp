import UIKit

final class IrregularEventCreatingViewController: CreatingViewController {
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedSchedule = Schedule(days: [.eternity])
        tableViewButtonsHeight = CGFloat(75)
        titleLabel.text = "Новое нерегулярное событие"
        setView()
    }
}

// MARK: - Extensions
extension IrregularEventCreatingViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
}


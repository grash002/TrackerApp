import UIKit

final class IrregularEventCreatingViewController: CreatingViewController {
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        selectedSchedule = Schedule(days: [.eternity])
        tableViewButtonsHeight = 75
        titleLabel.text = NSLocalizedString("creatingView.irregularEventTitle", comment: "")
        super.viewDidLoad()
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


import UIKit

final class HabitCreatingViewController: CreatingViewController {
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        titleLabel.text = NSLocalizedString("creatingView.habitTitle", comment: "")
        super.viewDidLoad()
    }
}

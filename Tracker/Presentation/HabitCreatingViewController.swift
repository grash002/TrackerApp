import UIKit

final class HabitCreatingViewController: CreatingViewController {
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "Новая привычка"
        setView()
    }
}

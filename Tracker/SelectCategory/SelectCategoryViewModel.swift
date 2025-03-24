import UIKit
final class SelectCategoryViewModel {
    
    weak var delegateTrackersView: TrackersViewControllerProtocol?
    weak var delegateCreatingView: CreatingViewControllerProtocol?

    var onCreateCategoryRequested: (() -> Void)?
    var categories: [TrackerCategory] {
        delegateTrackersView?.categories ?? []
    }

    init(delegateTrackersView: TrackersViewControllerProtocol?,
         delegateCreatingView: CreatingViewControllerProtocol?) {
        self.delegateTrackersView = delegateTrackersView
        self.delegateCreatingView = delegateCreatingView
    }
    
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func createButtonDidTap(controller: SelectCategoryViewController){
        onCreateCategoryRequested?()
    }

    func addCategory(title: String) {
        delegateCreatingView?.addCategory(toCategory: title)
    }
    
    func selectCategory(index: Int) {
        delegateCreatingView?.selectCategory(categoryTitle: categories[index].title)
    }
}

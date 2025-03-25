import UIKit
final class SelectCategoryViewModel {
    
    //MARK: - Public properties
    var onGetCategoriesRequested: (()-> [TrackerCategory]?)?
    var onAddCategoryRequested: ((String) -> Void)?
    var onSelectCategoryRequested: ((String) -> Void)?
    
    var onCreateCategoryRequested: (() -> Void)?
    
    var categories: [TrackerCategory] {
        onGetCategoriesRequested?() ?? []
    }
    
    //MARK: - Public methods
    func numberOfCategories() -> Int {
        categories.count
    }
    
    func createButtonDidTap(controller: SelectCategoryViewController){
        onCreateCategoryRequested?()
    }
    
    func addCategory(title: String) {
        onAddCategoryRequested?(title)
    }
    
    func selectCategory(index: Int) {
        onSelectCategoryRequested?(categories[index].title)
    }
}

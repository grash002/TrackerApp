import Foundation

protocol FiltersViewControllerDelegate: AnyObject {
    func setFilterState(_ : FilterState)
    var filterState: FilterState { get }
}

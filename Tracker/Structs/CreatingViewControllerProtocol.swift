import Foundation

protocol CreatingViewControllerProtocol: AnyObject {
    func addCategory(toCategory: String)
    func selectCategory(categoryTitle: String)
    func selectSchedule(schedule: Schedule)
}

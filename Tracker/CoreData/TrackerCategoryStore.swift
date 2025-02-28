import CoreData
import UIKit

final class TrackerCategoryStore {
    
    // MARK: - Public Properties
    static let shared = TrackerCategoryStore()

    // MARK: - Private Properties
    private let trackerStore = TrackerStore.shared
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // MARK: - Initializers
    private init() { }
    
    // MARK: - Public Methods
    func addTrackersCategory(idCategory: UUID, tracker: Tracker) {
        guard   let context,
                let appDelegate else { return }
        
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "idTrackerCategory == %@", idCategory as CVarArg)
        
        if let category = try? context.fetch(request).first {
            if var idTrackers = category.idTrackers {
                idTrackers.append(tracker.id.uuidString)
                category.idTrackers = idTrackers
            } else {
                let idTrackers = [tracker.id.uuidString]
                category.idTrackers = idTrackers
            }
        }
        appDelegate.saveContext()
        trackerStore.createTracker(tracker)
    }
    
    func createTrackerCategory(idCategory: UUID, categoryName: String) {
        guard   let context,
                let appDelegate else { return }
        
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "idTrackerCategory == %@", idCategory as CVarArg)
        
        do {
            if try context.fetch(request).isEmpty {
                let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
                trackerCategoryCoreData.idTrackerCategory = idCategory
                trackerCategoryCoreData.categoryName = categoryName
                
                appDelegate.saveContext()
            }
        } catch {
            print("Ошибка при создании категории: \(error.localizedDescription)")
        }
    }
    
    func fetchTrackersCategory() -> [TrackerCategory] {
        let fetchTrackers = trackerStore.fetchTrackers()
        
        let request = TrackerCategoryCoreData.fetchRequest()
        var trackerCategories: [TrackerCategory] = []
        
        do {
            let results = try context?.fetch(request)
            results?.forEach({
                if let idTrackerCategory = $0.idTrackerCategory,
                   let categoryName = $0.categoryName {
                    
                    let idTrackers = $0.idTrackers ?? []
                    let trackers: [Tracker] = idTrackers.compactMap { idTrackerString in
                        fetchTrackers.first(where: {$0.id == UUID(uuidString: idTrackerString)})
                   }
                    
                    let trackerCategory = TrackerCategory(idTrackerCategory: idTrackerCategory,
                                                          title: categoryName,
                                                          trackers: trackers )
                    trackerCategories.append(trackerCategory)
                
                } else {
                    print("Fetch error TrackerRecordCoreData: nils")
                }
            })
        } catch {
            print("Fetch error TrackerRecordCoreData: \(error.localizedDescription)")
        }
        
        return trackerCategories
    }
}

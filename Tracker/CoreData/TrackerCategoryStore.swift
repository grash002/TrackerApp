import CoreData
import UIKit

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Public Properties
    static let shared = TrackerCategoryStore()
    weak var delegate: TrackerCategoryStoreDelegate?

    // MARK: - Private Properties
    private let trackerStore = TrackerStore.shared
    private let dataBaseStore = DataBaseStore.shared
    private let context = DataBaseStore.shared.persistentContainer.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: - Initializers
    private override init() {
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Public Methods
    func addTrackersCategory(
        idCategory: UUID,
        tracker: Tracker
    ) {
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "idTrackerCategory == %@",
            idCategory as CVarArg
        )
        
        if let category = try? context.fetch(request).first {
            if let _ = category.idTrackers {
                category.idTrackers?.append(tracker.id.uuidString)
            } else {
                let idTrackers = [tracker.id.uuidString]
                category.idTrackers = idTrackers
            }
        }
        dataBaseStore.saveContext()
        trackerStore.createTracker(tracker)
    }
    
    func createTrackerCategory(
        idCategory: UUID,
        categoryName: String
    ) {
        
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "idTrackerCategory == %@",
            idCategory as CVarArg
        )
        
        do {
            if try context.fetch(request).isEmpty {
                let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
                trackerCategoryCoreData.idTrackerCategory = idCategory
                trackerCategoryCoreData.categoryName = categoryName
                
                dataBaseStore.saveContext()
            }
        } catch {
            print("Ошибка при создании категории: \(error.localizedDescription)")
        }
    }
    
    func fetchTrackersCategory() -> [TrackerCategory] {
        let fetchTrackers = trackerStore.fetchTrackers()
        
        return fetchedResultsController?.fetchedObjects?.compactMap { category in
            guard let idTrackerCategory = category.idTrackerCategory, let categoryName = category.categoryName else {
                print("Ошибка при извлечении данных TrackerCategoryCoreData")
                return nil
            }
            
            let idTrackers = category.idTrackers ?? []
            let trackers: [Tracker] = idTrackers.compactMap { idTrackerString in
                fetchTrackers.first { $0.id == UUID(uuidString: idTrackerString) }
            }
            
            return TrackerCategory(id: idTrackerCategory, title: categoryName, trackers: trackers)
        } ?? []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeTrackerCategory()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCategoryCoreData> = TrackerCategoryCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "categoryName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: request,
                                                              managedObjectContext: context,
                                                              sectionNameKeyPath: nil,
                                                              cacheName: nil)
        fetchedResultsController?.delegate = self
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка при загрузке данных: \(error.localizedDescription)")
        }
    }
}

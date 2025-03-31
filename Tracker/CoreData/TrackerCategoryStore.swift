import CoreData
import UIKit

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Public Properties
    static let shared = TrackerCategoryStore()
    weak var delegate: TrackerCategoryStoreDelegate?
    var categories: [TrackerCategory]?
    
    // MARK: - Private Properties
    private let trackerStore = TrackerStore.shared
    private let trackerRecordStore = TrackerRecordStore.shared
    private let dataBaseStore = DataBaseStore.shared
    private let context = DataBaseStore.shared.persistentContainer.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCoreData>?
    
    // MARK: - Initializers
    private override init() {
        super.init()
        
        setupFetchedResultsController()
        categories = fetchTrackersCategory()
    }
    
    // MARK: - Public Methods
    func updateTrackersCategory(tracker: Tracker?, idCategory: UUID, categoryName: String?) {
        if let tracker,
           let index = categories?.firstIndex(where: {$0.id == idCategory}){
            
            deleteTrackersCategory(id: tracker.id)
            
            categories?[index].trackers.append(tracker)
        }
        
        if var categories,
           let categoryName,
           !categories.contains(where: {$0.id == idCategory}) {
            categories.append(TrackerCategory(id: idCategory, title: categoryName, trackers: []))
            self.categories = categories
        }
    }
        
    func deleteTrackersCategory(id: UUID) {
        for i in 0..<(categories?.count ?? 0) {
            self.categories?[i].trackers.removeAll(where: { $0.id == id })
        }
    }
    
    func togglePinnedTracker(id: UUID) {
        if let indexCategory = categories?.firstIndex(where: {$0.trackers.contains(where: {$0.id == id}) }),
           let indexTracker = categories?[indexCategory].trackers.firstIndex(where: {$0.id == id}) {
            categories?[indexCategory].trackers[indexTracker].pinnedFlag.toggle()
            
            guard let categories else { return }
            trackerStore.updateTracker(tracker: categories[indexCategory].trackers[indexTracker])
        }
    }
    
    func addTrackersCategory(idCategory: UUID, tracker: Tracker) {
        
        updateTrackersCategory(tracker: tracker, idCategory: idCategory, categoryName: nil)
        
        removeTrackerFromCore(id: tracker.id)
        
        let request = TrackerCategoryCoreData.fetchRequest()
        request.predicate = NSPredicate(
            format: "idTrackerCategory == %@",
            idCategory as CVarArg
        )
        
        if let category = try? context.fetch(request).first {
            var ids = category.idTrackers ?? []
            if !ids.contains(tracker.id.uuidString) {
                ids.append(tracker.id.uuidString)
                category.idTrackers = ids
            }
        }
        dataBaseStore.saveContext()
        trackerStore.createTracker(tracker)
    }
    
    func createTrackerCategory(idCategory: UUID, categoryName: String){
        updateTrackersCategory(tracker: nil,
                               idCategory: idCategory,
                               categoryName: categoryName)
        
        
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
    
    func removeTrackerFromCore(id: UUID) {
        let request = TrackerCategoryCoreData.fetchRequest()
        
        if let categories = try? context.fetch(request){
            for category in categories {
                if let ids = category.idTrackers, ids.contains(id.uuidString) {
                    category.idTrackers = ids.filter { $0 != id.uuidString }
                }
            }
        }
        dataBaseStore.saveContext()
        
        trackerRecordStore.deleteRecords(id: id)
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

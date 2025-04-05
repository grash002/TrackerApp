import CoreData
import UIKit

final class TrackerStore: NSObject, NSFetchedResultsControllerDelegate {
    // MARK: - Public Properties
    static let shared = TrackerStore()
    
    // MARK: - Private Properties
    private let dataBaseStore = DataBaseStore.shared
    private let context = DataBaseStore.shared.persistentContainer.viewContext
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    
    // MARK: - Initializers
    private override init() {
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "trackerName", ascending: true)]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController?.delegate = self
        
        do {
            try fetchedResultsController?.performFetch()
        } catch {
            print("Ошибка при загрузке данных: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Public Methods
    func createTracker(_ tracker: Tracker) {
        let request = TrackerCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "idTracker == %@", tracker.id as CVarArg)
        
        do {
            let existingTrackers = try context.fetch(request)
            
            let trackerCoreData: TrackerCoreData
            
            if let existing = existingTrackers.first {
                trackerCoreData = existing
            } else {
                trackerCoreData = TrackerCoreData(context: context)
                trackerCoreData.idTracker = tracker.id
            }
            
            trackerCoreData.trackerName = tracker.name
            trackerCoreData.colorHex = tracker.colorHex
            trackerCoreData.emoji = tracker.emoji
            trackerCoreData.schedule = tracker.schedule.toString()
            trackerCoreData.pinnedFlag = tracker.pinnedFlag
            
            dataBaseStore.saveContext()
            
        } catch {
            print("Failed to fetch tracker: \(error)")
        }
        
    }
    
    func updateTracker(tracker: Tracker) {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idTracker = %@", tracker.id as CVarArg)
        do {
            if let existingTracker = try context.fetch(fetchRequest).first {
                existingTracker.colorHex = tracker.colorHex
                existingTracker.emoji = tracker.emoji
                existingTracker.pinnedFlag = tracker.pinnedFlag
                existingTracker.trackerName = tracker.name
                dataBaseStore.saveContext()
            }
        } catch {
            print("Failed to fetch tracker for update: \(error.localizedDescription)")
        }
    }
    
    func fetchTrackers() -> [Tracker] {
        
        guard let fetchedResultsController else { return [] }
        do {
            try fetchedResultsController.performFetch()
            guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return [] }
            
            let trackers: [Tracker] = fetchedObjects.compactMap { item in
                if let idTracker = item.idTracker,
                   let trackerName = item.trackerName,
                   let colorHex = item.colorHex,
                   let emoji = item.emoji,
                   let schedule = Schedule.toSchedule(from: item.schedule ?? "") {
                    return Tracker(id: idTracker,
                                   name: trackerName,
                                   colorHex: colorHex,
                                   emoji: emoji,
                                   schedule: schedule,
                                   pinnedFlag: item.pinnedFlag)
                } else {
                    return nil
                }
            }
            
            return trackers
            
        } catch {
            print("Ошибка при выполнении fetch: \(error.localizedDescription)")
            return []
        }
    }
}

import CoreData
import UIKit

final class TrackerRecordStore: NSObject, NSFetchedResultsControllerDelegate {
    
    // MARK: - Public Properties
    static let shared = TrackerRecordStore()
    weak var delegate: TrackerRecordStoreDelegate?
    
    // MARK: - Private Properties
    private let dataBaseStore = DataBaseStore.shared
    private let context = DataBaseStore.shared.persistentContainer.viewContext
    private let calendar = Calendar.current
    private var fetchedResultsController: NSFetchedResultsController<TrackerRecordCoreData>?
    
    // MARK: - Initializers
    private override init() {
        super.init()
        setupFetchedResultsController()
    }
    
    // MARK: - Private Methods
    private func setupFetchedResultsController() {
        let request: NSFetchRequest<TrackerRecordCoreData> = TrackerRecordCoreData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "idTracker", ascending: true)]
        
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
    func createTrackerRecord(trackerId: UUID, trackingDate: Date) {
        if let result = fetchedResultsController?.fetchedObjects?.first(where: { $0.idTracker == trackerId }) {
            if var trackingDates = result.trackingDates,
               !trackingDates.contains(where: { calendar.isDate($0, inSameDayAs: trackingDate) }) {
                trackingDates.append(trackingDate)
                result.trackingDates = trackingDates
            } else {
                result.trackingDates = [trackingDate]
            }
        } else {
            let trackerRecordCoreData = TrackerRecordCoreData(context: context)
            trackerRecordCoreData.idTracker = trackerId
            trackerRecordCoreData.trackingDates = [trackingDate]
        }
        dataBaseStore.saveContext()
    }
    
    func deleteTrackerRecord(trackerId: UUID, trackingDate: Date) {
        if let result = fetchedResultsController?.fetchedObjects?.first(where: { $0.idTracker == trackerId }),
           var dates = result.trackingDates {
            dates.removeAll { calendar.isDate($0, inSameDayAs: trackingDate) }
            result.trackingDates = dates
            dataBaseStore.saveContext()
        }
    }
    
    func fetchTrackerRecords() -> [CompletedTrackers] {
        return fetchedResultsController?.fetchedObjects?.compactMap { item in
            guard let idTracker = item.idTracker else { return nil }
            let trackingDates = item.trackingDates ?? []
            return CompletedTrackers(trackerId: idTracker, dates: trackingDates)
        } ?? []
    }
    
    func deleteRecords(id: UUID) {
        let fetchRequest = TrackerRecordCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "idTracker == %@", id as CVarArg)

        if let results = try? context.fetch(fetchRequest){
            for record in results {
                context.delete(record)
            }
        }
        dataBaseStore.saveContext()
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.storeTrackerRecord()
    }
}

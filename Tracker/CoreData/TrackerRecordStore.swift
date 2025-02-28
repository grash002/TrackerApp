import CoreData
import UIKit

final class TrackerRecordStore {
    
    // MARK: - Public Properties
    static let shared = TrackerRecordStore()
 
    // MARK: - Private Properties
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    private let calendar = Calendar.current
    
    // MARK: - Initializers
    private init() { }
    
    // MARK: - Public Methods
    func createTrackerRecord(trackerId: UUID, trackingDate: Date) {
        guard   let context,
                let appDelegate else { return }
        
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "idTracker == %@", trackerId as CVarArg)
        
        if let result = try? context.fetch(request).first {
            if var trackingDates = result.trackingDates,
               !trackingDates.contains(where: { calendar.isDate($0, inSameDayAs: trackingDate)}) {
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
        
        
        appDelegate.saveContext()
    }
    
    func deleteTrackerRecord(trackerId: UUID, trackingDate: Date) {
        guard   let context,
                let appDelegate else { return }
        let request = TrackerRecordCoreData.fetchRequest()
        request.predicate = NSPredicate(format: "idTracker == %@", trackerId as CVarArg)
        
        if let result = try? context.fetch(request).first,
           var dates = result.trackingDates {
            dates.removeAll { calendar.isDate($0, inSameDayAs: trackingDate) }
            result.trackingDates = dates
            appDelegate.saveContext()
        }
    }
    
    func fetchTrackerRecords() -> [CompletedTrackers] {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        var fetchedTrackerRecords: [CompletedTrackers] = []
        
        do {
            let results = try context?.fetch(request)
            results?.forEach({ item in
                if let idTracker = item.idTracker{
                    if let trackingDates = item.trackingDates {
                        fetchedTrackerRecords.append(CompletedTrackers(trackedId: idTracker,
                                                                       dates: trackingDates))
                    } else {
                        fetchedTrackerRecords.append(CompletedTrackers(trackedId: idTracker,
                                                                           dates: []))
                    }
                }
            })
        } catch {
            print("Fetch error TrackerRecordCoreData: \(error.localizedDescription)")
        }
        
        return fetchedTrackerRecords
    }
}

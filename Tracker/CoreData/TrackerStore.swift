import CoreData
import UIKit

final class TrackerStore {
    // MARK: - Public Properties
    static let shared = TrackerStore()
    
    // MARK: - Private Properties
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    // MARK: - Initializers
    private init() { }
    
    // MARK: - Public Methods
    func createTracker(_ tracker: Tracker) {
        guard   let context,
                let appDelegate else { return }
        let trackerCoreData = TrackerCoreData(context: context)
        trackerCoreData.idTracker = tracker.id
        trackerCoreData.trackerName = tracker.name
        trackerCoreData.colorHex = tracker.color
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = tracker.schedule.toString()
        
        appDelegate.saveContext()
    }
    
    func fetchTrackers() -> [Tracker] {
        let request: NSFetchRequest<TrackerCoreData> = TrackerCoreData.fetchRequest()
        let result = (try? context?.fetch(request)) ?? []
        let trackers: [Tracker] = result.compactMap({ item in
            guard let idTracker = item.idTracker,
                  let trackerName = item.trackerName,
                  let colorHex = item.colorHex,
                  let emoji = item.emoji,
                  let schedule = Schedule.toSchedule(from: item.schedule ?? "") else { return nil }
            return Tracker(id: idTracker,
                    name: trackerName,
                    color: colorHex,
                    emoji: emoji,
                    schedule: schedule)
        })
        return trackers
    }
}


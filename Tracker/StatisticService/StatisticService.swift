import Foundation

final class StatisticService {
    static let shared = StatisticService()
    private let trackerRecordStore = TrackerRecordStore.shared
    
    
    func calculateStatistics() -> [String: Int] {
        let completed = trackerRecordStore.fetchTrackerRecords()
        var allDatesByTracker: [UUID: Set<Date>] = [:]
        var allDates: [Date: Int] = [:]
        var allCompletedCount = 0

        let calendar = Calendar.current

        for tracker in completed {
            let uniqueDates = Set(tracker.dates.map { calendar.startOfDay(for: $0) })
            allDatesByTracker[tracker.trackerId] = uniqueDates

            for date in uniqueDates {
                allDates[date, default: 0] += 1
            }

            allCompletedCount += uniqueDates.count
        }

        var bestPeriod = 0
        for dates in allDatesByTracker.values {
            let sorted = dates.sorted()
            var currentStreak = 1
            var maxStreak = 1
            guard sorted.count > 1 else { continue }
            for i in 1..<sorted.count {
                if calendar.date(byAdding: .day, value: 1, to: sorted[i - 1]) == sorted[i] {
                    currentStreak += 1
                } else {
                    maxStreak = max(maxStreak, currentStreak)
                    currentStreak = 1
                }
            }
            maxStreak = max(maxStreak, currentStreak)
            bestPeriod = max(bestPeriod, maxStreak)
        }

        let perfectDayCount = allDates.filter { $0.value == allDatesByTracker.count }.count

        let uniqueDays = Set(allDates.keys)
        let averagePerDay = uniqueDays.isEmpty ? 0 : Int(round(Double(allCompletedCount) / Double(uniqueDays.count)))

        return [
            "statisticView.BestPeriod": bestPeriod,
            "statisticView.PerfectDay": perfectDayCount,
            "statisticView.Completed": allCompletedCount,
            "statisticView.Average": averagePerDay
        ]
    }

    
    private init() { }
}

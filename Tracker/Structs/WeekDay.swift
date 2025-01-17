import Foundation

enum WeekDay: Int, Comparable {
    case monday = 0
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
    
    static func < (lhs: WeekDay, rhs: WeekDay) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

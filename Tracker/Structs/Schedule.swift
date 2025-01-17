import Foundation

struct Schedule {
    var days: [WeekDay]

    mutating func add(weekday: WeekDay) {
        guard !days.contains(weekday) else { return }
        
        if let index = days.firstIndex(where: {$0.rawValue > weekday.rawValue}) {
            days.insert(weekday, at: index)
        } else {
            days.append(weekday)
        }
    }
    
    func toString() -> String {
        var result = ""
        let dict = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс",]
        if days.count == dict.count {
            return "Каждый день"
        } else {
            days.forEach({ result.append("\(dict[$0.rawValue]), ") })
            result = String(result.dropLast(2))
            return result
        }
    }
}

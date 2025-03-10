import Foundation

struct Schedule {
    var days: [WeekDay]
    let calendar = Calendar.current
    static let stringWeekdays = ["Пн","Вт","Ср","Чт","Пт","Сб","Вс",]

    static func toSchedule(from rawString: String) -> Schedule? {
    
        let rawWeekdays = rawString.components(separatedBy: ",")
        var weekDays: [WeekDay] = []
        
        for rawWeekDay in rawWeekdays {
            let tempStringWeekDay = rawWeekDay.trimmingCharacters(in: .whitespacesAndNewlines)
            if tempStringWeekDay == String(describing: WeekDay.eternity) { return Schedule(days: [.eternity]) }
            
            guard let index = stringWeekdays.firstIndex(where: {$0 == tempStringWeekDay}),
                  let weekday = WeekDay(rawValue: index) else { return nil }
            weekDays.append(weekday)
        }
        
        return Schedule(days: weekDays)
    }
    
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
        if days.count == Schedule.stringWeekdays.count {
            return "Каждый день"
        } 
        if days[0] == .eternity {
            return String(describing: WeekDay.eternity)
        } else {
            days.forEach({ result.append("\(Schedule.stringWeekdays[$0.rawValue]), ") })
            result = String(result.dropLast(2))
            return result
        }
    }
    
    func isSelected(selectedDate: Date) -> Bool {
        var weekDay = calendar.component(.weekday, from: selectedDate)
        weekDay = weekDay == 1 ? 6 : weekDay - 2
        return days.contains(where: {$0.rawValue == weekDay || $0 == .eternity} )
    }
}

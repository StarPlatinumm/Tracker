import UIKit

// Структура для хранения информации о привычках
struct Tracker {
    let id: UInt
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
}

// Структура для хранения категорий трекеров
struct TrackerCategory {
    let title: String
    let trackers: [Tracker]
}

// Структура для хранения записи о выполнении трекера на определенную дату
struct TrackerRecord {
    let trackerID: UInt
    let date: Date
}

// Дни недели
enum Weekday: String {
    case monday = "Понедельник"
    case tuesday = "Вторник"
    case wednesday = "Среда"
    case thursday = "Четверг"
    case friday = "Пятница"
    case saturday = "Суббота"
    case sunday = "Воскресенье"
}

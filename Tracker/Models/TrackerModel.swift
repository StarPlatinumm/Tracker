import UIKit

// Структура для хранения информации о привычках
struct Tracker {
    let id: String
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Weekday]
    let category: String
    let computedCategory: String
    let isPinned: Bool
}

enum Weekday: Int, Codable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}


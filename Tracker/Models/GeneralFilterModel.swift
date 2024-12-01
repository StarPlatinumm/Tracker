import Foundation

enum GeneralFilter: String, CaseIterable {
    case all
    case today
    case done
    case undone
    
    var localized: String {
        switch self {
        case .all:
            return NSLocalizedString("trackers.filters.all", comment: "Все трекеры")
        case .today:
            return NSLocalizedString("trackers.filters.today", comment: "Трекеры на сегодня")
        case .done:
            return NSLocalizedString("trackers.filters.done", comment: "Завершенные")
        case .undone:
            return NSLocalizedString("trackers.filters.undone", comment: "Не завершенные")
        }
    }
}

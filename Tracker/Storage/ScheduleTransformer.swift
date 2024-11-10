import UIKit


final class ScheduleTransformer {
    func toString(_ schedule: [Weekday]) -> String {
        return schedule.map { String($0.rawValue) }.joined(separator: ", ")
    }

    func toWeekdays(_ string: String) -> [Weekday] {
        return string.components(separatedBy: ", ").compactMap { Weekday(rawValue: Int($0) ?? 0) }
    }
}

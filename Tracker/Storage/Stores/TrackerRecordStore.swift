import UIKit
import CoreData

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
    
    func addTrackerRecord(trackerID: String, date: Date) throws {
        let trackerRecord = TrackerRecordCoreData(context: context)
        trackerRecord.trackerID = trackerID
        trackerRecord.date = Calendar.current.startOfDay(for: date)
        try context.save()
    }
    
    func removeTrackerRecord(trackerID: String, date: Date) throws {
        let fetchRequest = fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerID as CVarArg, startOfDay as NSDate)
        
        let records = try context.fetch(fetchRequest)
        for record in records {
            context.delete(record)
        }
        try context.save()
    }
    
    func getTrackerRecords(by trackerID: String) throws -> [TrackerRecord] {
        let fetchRequest = fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@", trackerID as CVarArg)
        var trackerRecords: [TrackerRecord] = []
        var trackerRecordsCoreData: [TrackerRecordCoreData] = []

        trackerRecordsCoreData = try context.fetch(fetchRequest)
        for record in trackerRecordsCoreData {
            if let trackerID = record.trackerID, let recordDate = record.date {
                trackerRecords.append(TrackerRecord(trackerID: trackerID, date: recordDate))
            }
        }
        return trackerRecords
    }
    
    func isTrackerCompleted(trackerID: String, date: Date) throws -> Bool  {
        let fetchRequest = fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        fetchRequest.predicate = NSPredicate(format: "trackerID == %@ AND date == %@", trackerID as CVarArg, startOfDay as NSDate)
        
        let count = try context.count(for: fetchRequest)
        return count > 0
    }
}

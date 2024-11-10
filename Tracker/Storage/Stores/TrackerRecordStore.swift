import UIKit
import CoreData

enum TrackerError: Error {
    case invalidTrackerID
}

final class TrackerRecordStore {
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }
    
    func addTrackerRecord(trackerID: String, date: Date) throws {
        // сначала получаем трекер
        guard
            let url = URL(string: trackerID),
            let objectID = context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: url),
            let tracker = try? context.existingObject(with: objectID) as? TrackerCoreData else {
            throw TrackerError.invalidTrackerID
        }
        
        // потом создаём новую запись
        let trackerRecord = TrackerRecordCoreData(context: context)
        trackerRecord.trackerID = trackerID
        trackerRecord.date = Calendar.current.startOfDay(for: date)
        trackerRecord.tracker = tracker
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

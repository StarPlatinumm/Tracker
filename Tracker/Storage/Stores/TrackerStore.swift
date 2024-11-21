import UIKit
import CoreData

final class TrackerStore {
    private let context: NSManagedObjectContext
    private let uiColorMarshalling = UIColorMarshalling()
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }
    
    func addNewTracker(tracker: Tracker) {
        let fetchRequest = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        fetchRequest.predicate = NSPredicate(format: "title == %@", tracker.category)
        var categories: [TrackerCategoryCoreData] = []
        do {
            categories = try context.fetch(fetchRequest)
        } catch {
            print("Failed to request categories")
        }
        
        let category: TrackerCategoryCoreData
        if let existingCategory = categories.first {
            category = existingCategory
        } else {
            category = TrackerCategoryCoreData(context: context)
            category.title = tracker.category
        }
        
        let trackerForDB = TrackerCoreData(context: context)
        trackerForDB.color = uiColorMarshalling.hexString(from: tracker.color)
        trackerForDB.emoji = tracker.emoji
        trackerForDB.schedule = ScheduleTransformer().toString(tracker.schedule)
        trackerForDB.name = tracker.name
        
        trackerForDB.category = category
        category.addToTrackers(trackerForDB)
        do {
            try context.save()
        } catch {
            print("Failed to save changes to context")
        }
    }
    
    func createTracker(from TrackerCoreData: TrackerCoreData) -> Tracker? {
        guard let trackerTitle = TrackerCoreData.name,
              let trackerColorString = TrackerCoreData.color,
              let trackerScheduleString = TrackerCoreData.schedule,
              let trackerEmoji = TrackerCoreData.emoji,
              let trackerCategory = TrackerCoreData.category?.title
        else {
            return nil
        }
        
        let trackerColor = uiColorMarshalling.color(from: trackerColorString)
        let trackerSchedule = ScheduleTransformer().toWeekdays(trackerScheduleString)
        
        let tracker = Tracker(
            id: TrackerCoreData.objectID.uriRepresentation().absoluteString,
            name: trackerTitle,
            color: trackerColor,
            emoji: trackerEmoji,
            schedule: trackerSchedule,
            category: trackerCategory
        )
        return tracker
    }
    
    func getTrackers() throws -> [Tracker] {
        var trackersArray: [Tracker] = []
        let request = fetchRequest()
        let trackersFromDB = try context.fetch(request)
        for i in trackersFromDB {
            if let newTracker = createTracker(from: i) {
                trackersArray.append(newTracker)
            } else {
                print("Failed to create tracker from TrackerCoreData")
            }
        }
        return trackersArray
    }
    
    func getTrackersCD() throws -> [TrackerCoreData] {
        let request = fetchRequest()
        let trackersFromDB = try context.fetch(request)
        return trackersFromDB
    }
}

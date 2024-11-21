import UIKit
import CoreData


final class TrackerCategoryStore {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    private func fetchRequest() -> NSFetchRequest<TrackerCategoryCoreData> {
        return NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
    }
    
    func addTrackerCategory(_ categoryTitle: String) throws {
        let category = TrackerCategoryCoreData(context: context)
        category.title = categoryTitle
        try context.save()
    }
    
    func getTrackerCategoryNames() throws -> [String] {
        let fetchRequest = fetchRequest()
        
        var trackerCategories: [String] = []
        var trackerCategoryCoreData: [TrackerCategoryCoreData] = []

        trackerCategoryCoreData = try context.fetch(fetchRequest)
        for category in trackerCategoryCoreData {
            if let categoryTitle = category.title {
                trackerCategories.append(categoryTitle)
            }
        }
        return trackerCategories
    }
}

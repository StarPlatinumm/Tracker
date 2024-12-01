import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func addRecord(_ record: Tracker) throws
    
    func getTrackers() -> [Tracker]
    func pinTracker(_ trackerID: String, setTo value: Bool)
    func editTracker(_ tracker: Tracker)
    func removeTracker(_ trackerID: String)
    func filterTrackers(date: Date, searchFilter: String, doneFilter: Bool?)
    
    func addCategory(categoryTitle: String)
    func getCategoryNames() -> [String]
    
    func addTrackerRecord(trackerID: String, date: Date)
    func removeTrackerRecord(trackerID: String, date: Date)
    func isTrackerCompleted(trackerID: String, date: Date) -> Bool
    func getTrackerRecords(by trackerID: String) -> [TrackerRecord]
}

// MARK: - DataProvider
final class DataProvider: NSObject {
    
    enum DataProviderError: Error {
        case failedToInitializeContext
    }
    
    weak var delegate: DataProviderDelegate?
    
    private let context: NSManagedObjectContext
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    // контроллер для обновления коллекции трекеров
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "isPinned", ascending: false)]
        
        let currentwWeekday = getCorrectWeekdayNum(from: Date())
        fetchRequest.predicate = NSPredicate(
            format: "name LIKE[c] %@ AND (schedule LIKE %@ OR ANY record.date = %@ OR (record.@count == 0 AND schedule == ''))",
            argumentArray: ["*", "*\(currentwWeekday)*", Calendar.current.startOfDay(for: Date())]
        )
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "computedCategory",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init?(delegate: DataProviderDelegate) throws {
        let container = NSPersistentContainer(name: "Trackers")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        let context = container.viewContext
        
        self.delegate = delegate
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
    }
    
    private func getCorrectWeekdayNum(from date: Date) -> String {
        // преобразуем так, чтобы пн = 0, ..., вс = 6
        return String((Calendar.current.component(.weekday, from: date) + 5) % 7)
    }
    
    func filterTrackers(date: Date, searchFilter: String, doneFilter: Bool?) {
        let weekday = getCorrectWeekdayNum(from: date)
        
        var formatString = "name LIKE[c] %@ AND (schedule LIKE %@ OR ANY record.date = %@ OR (record.@count == 0 AND schedule == ''))"
        var arguments: [Any] = ["*\(searchFilter)*", "*\(weekday)*", Calendar.current.startOfDay(for: date)]
        
        if let doneFilter {
            if doneFilter {
                formatString += " AND SUBQUERY(record, $r, $r.date == %@).@count > 0"
            } else {
                formatString += " AND SUBQUERY(record, $r, $r.date == %@).@count == 0"
            }
            arguments.append(Calendar.current.startOfDay(for: date))
        }
        
        print("formatString: \(formatString)")
        
        fetchedResultsController.fetchRequest.predicate = NSPredicate(format: formatString, argumentArray: arguments)
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error fetching data with new predicate: \(error)")
        }
    }
}

// для работы с TrackerStore
extension DataProvider {
    func getTrackers() -> [Tracker] {
        do {
            let result = try trackerStore.getTrackers()
            return result
        } catch {
            print("Failed to get trackers: \(error)")
            return []
        }
    }
    
    func pinTracker(_ trackerID: String, setTo value: Bool) {
        do {
            try trackerStore.pinTracker(trackerID, value: value)
        } catch {
            print("Failed to pin tracker: \(error)")
        }
    }
    
    func editTracker(_ tracker: Tracker) {
        do {
            try trackerStore.editTracker(tracker)
        } catch {
            print("Failed to edit tracker: \(error)")
        }
    }
    
    func removeTracker(_ trackerID: String) {
        do {
            try trackerStore.removeTracker(trackerID)
        } catch {
            print("Failed to remove tracker: \(error)")
        }
    }
}

// для работы с TrackerRecordStore
extension DataProvider {
    func addTrackerRecord(trackerID: String, date: Date) {
        do {
            try trackerRecordStore.addTrackerRecord(trackerID: trackerID, date: date)
        } catch {
            print("Failed to add tracker entry: \(error)")
        }
    }
    
    func removeTrackerRecord(trackerID: String, date: Date) {
        do {
            try trackerRecordStore.removeTrackerRecord(trackerID: trackerID, date: date)
        } catch {
            print("Failed to delete tracker entry: \(error)")
        }
    }
    
    func isTrackerCompleted(trackerID: String, date: Date) -> Bool {
        do {
            let result = try trackerRecordStore.isTrackerCompleted(trackerID: trackerID, date: date)
            return result
        } catch {
            print("Failed to verify tracker completion: \(error)")
            return false
        }
    }
    
    func getTrackerRecords(by trackerID: String) -> [TrackerRecord] {
        do {
            let result = try trackerRecordStore.getTrackerRecords(by: trackerID)
            return result
        } catch {
            print("Failed to get Tracker's records: \(error)")
            return []
        }
    }
}

// для работы с TrackerCategory
extension DataProvider {
    func addCategory(categoryTitle: String) {
        do {
            try trackerCategoryStore.addTrackerCategory(categoryTitle)
        } catch {
            print("Failed to get category: \(error)")
        }
    }
    
    func getCategoryNames() -> [String] {
        do {
            let result = try trackerCategoryStore.getTrackerCategoryNames()
            return result
        } catch {
            print("Failed to get categories: \(error)")
            return []
        }
    }
}

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerStore.createTracker(from: trackerCoreData)
    }
    
    func addRecord(_ record: Tracker) throws {
        trackerStore.addNewTracker(tracker: record)
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let insertedIndexes, let deletedIndexes else { return }
        
        delegate?.didUpdate(TrackerStoreUpdate(
            insertedIndexes: insertedIndexes,
            deletedIndexes: deletedIndexes
        )
        )
        self.insertedIndexes = nil
        self.deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}

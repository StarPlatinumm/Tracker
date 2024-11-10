import UIKit
import CoreData

struct TrackerStoreUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol DataProviderDelegate: AnyObject {
    func didUpdate(_ update: TrackerStoreUpdate)
    func updateFilters()
}

protocol DataProviderProtocol {
    var numberOfSections: Int { get }
    func numberOfItemsInSection(_ section: Int) -> Int
    func object(at: IndexPath) -> Tracker?
    func addRecord(_ record: Tracker) throws
    
    func getTrackers() -> [Tracker]
    func filterTrackers(date: Date, filter: String)
    
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
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {

        let fetchRequest = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        let currentwWeekday = String((Calendar.current.component(.weekday, from: Date()) + 5) % 7) // преобразуем так, чтобы пн = 0, ..., вс = 6
        fetchRequest.predicate = NSPredicate(format: "schedule LIKE[c] %@", argumentArray: ["*\(currentwWeekday)*"])
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: "category",
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        try? fetchedResultsController.performFetch()
        return fetchedResultsController
    }()
    
    init(delegate: DataProviderDelegate) throws {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        self.delegate = delegate
        self.context = context
        self.trackerStore = TrackerStore(context: context)
        self.trackerCategoryStore = TrackerCategoryStore(context: context)
        self.trackerRecordStore = TrackerRecordStore(context: context)
    }
    
    func filterTrackers(date: Date, filter: String) {
        let weekday = String((Calendar.current.component(.weekday, from: date) + 5) % 7) // преобразуем так, чтобы пн = 0, ..., вс = 6
        
        let newPredicate = NSPredicate(format: "schedule LIKE[c] %@ AND name LIKE[c] %@", argumentArray: ["*\(weekday)*", "*\(filter)*"])

        fetchedResultsController.fetchRequest.predicate = newPredicate

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
            print("Failed to get Trackers: \(error)")
            return []
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

// MARK: - DataProviderProtocol
extension DataProvider: DataProviderProtocol {
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func object(at indexPath: IndexPath) -> Tracker? {
        let trackerCoreData = fetchedResultsController.object(at: indexPath)
        return trackerStore.createTracker(from: trackerCoreData)
    }

    func addRecord(_ record: Tracker) throws {
        trackerStore.addNewTracker(tracker: record, categoryName: "Новые")
    }
}

// MARK: - NSFetchedResultsControllerDelegate
extension DataProvider: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerStoreUpdate(
                insertedIndexes: insertedIndexes!,
                deletedIndexes: deletedIndexes!
            )
        )
        insertedIndexes = nil
        deletedIndexes = nil
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

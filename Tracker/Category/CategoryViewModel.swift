
import Foundation

typealias Binding<T> = (T) -> Void

final class CategoryViewModel {
    
    var categories: [String] = []
    var returnCategory: Binding<String>?
    var updateCategories: Binding<[String]>?
    
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            try dataProvider = DataProvider(delegate: self)
            return dataProvider
        } catch {
            print("Данные недоступны.")
            return nil
        }
    }()
    
    func getCategories() {
        categories = dataProvider?.getCategoryNames() ?? []
        updateCategories?(categories)
    }
    
    func addNewCategory(_ newCategory: String) {
        categories.append(newCategory)
        dataProvider?.addCategory(categoryTitle: newCategory)
        updateCategories?(categories)
    }
    
    func pickCategory(_ category: String) {
        returnCategory?(category)
    }
}

extension CategoryViewModel: DataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        // stub
    }
}

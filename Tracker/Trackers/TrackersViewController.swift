import UIKit


// экран с коллекцией трекеров
final class TrackersViewController: UIViewController {
    
    private lazy var addButton: UIBarButtonItem = {
        let button = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        button.tintColor = UIColor.ypBlack
        return button
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchBarController: UISearchController = {
        let searchBarController = UISearchController(searchResultsController: nil)
        searchBarController.searchBar.placeholder = "Поиск"
        searchBarController.searchBar.delegate = self
        return searchBarController
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var trackersCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: TrackerCollectionCell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        return collection
    }()
    
    private lazy var emptyTrackersImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackers-placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyTrackersTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var currentDate = Date()
    private var filterValue: String = ""
    private let collectionParams = GeometricParams(cellCount: 2, leftInset: 0, rightInset: 0, cellSpacing: 9)
    
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            try dataProvider = DataProvider(delegate: self)
            return dataProvider
        } catch {
            print("Данные недоступны.")
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchBarController
        
        mainStackView.addArrangedSubview(trackersCollection)
        scrollView.addSubview(mainStackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            trackersCollection.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
        ])
    }
    
    // проверяет, отмечен ли трекер как выполненный в текущую дату
    private func isTrackerCompleteOnCurrentDate(_ trackerID: String) -> Bool {
        return self.dataProvider?.isTrackerCompleted(trackerID: trackerID, date: currentDate) ?? false
    }
    
    // в какие даты был выполнен трекер
    private func getTrackerRecords(_ trackerID: String) -> Int {
        return dataProvider?.getTrackerRecords(by: trackerID).count ?? 0
    }
    
    // возвращает строку с кол-вом дней, в который трекер выполнялся
    private func getTrackerDaysLabelText(for tracker: Tracker) -> String {
        
        // для нерегулярных событий нет смысла считать дни
        if tracker.schedule.isEmpty {
            return ""
        }
        
        let days = dataProvider?.getTrackerRecords(by: tracker.id).count ?? 0
        
        if days % 10 == 1 && days % 100 != 11 {
            return "\(days) день"
        } else if (days % 10 == 2 || days % 10 == 3 || days % 10 == 4) && (days % 100 < 10 || days % 100 > 20) {
            return "\(days) дня"
        } else {
            return "\(days) дней"
        }
    }
    
    // добавляет новый трекер в коллекцию
    private func addTracker(_ tracker: Tracker, categoryName: String) {
        searchBarController.searchBar.text = ""
        try? dataProvider?.addRecord(tracker)
    }
    
    func updateFilters() {
        dataProvider?.filterTrackers(date: currentDate, filter: filterValue)
        trackersCollection.reloadData()
    }
    
    // обновление текущей даты
    @objc private func dateChanged() {
        currentDate = datePicker.date
        updateFilters()
    }
    
    // добавление нового трекера
    @objc private func addTapped() {
        present(UINavigationController(rootViewController: TrackerTypeSelectionViewController(onAddTracker: addTracker)), animated: true, completion: nil)
    }
}

// UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // количество категорий
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        let sectionsCount = dataProvider?.numberOfSections ?? 0
        if (sectionsCount == 0) {
            let totalTrackersCount = dataProvider?.getTrackers().count ?? 0
            if (totalTrackersCount == 0) {
                setBGViewToCollection(trackersCollection, imageName: "trackers-placeholder", text: "Что будем отслеживать?")
            } else {
                setBGViewToCollection(trackersCollection, imageName: "no-trackers-found", text: "Ничего не найдено")
            }
        } else {
            trackersCollection.backgroundView = nil
        }
        
        return sectionsCount
    }
    
    // количество ячеек в каждой категории
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let result =  dataProvider?.numberOfItemsInSection(section) ?? 0
        return result
    }
    
    // настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let tracker = dataProvider?.object(at: indexPath) else { return UICollectionViewCell() }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionCell.identifier, for: indexPath) as! TrackerCollectionCell
        
        cell.emojiLabel.text = tracker.emoji
        cell.textLabel.text = tracker.name
        cell.infoLabel.text = getTrackerDaysLabelText(for: tracker)
        cell.cardView.backgroundColor = tracker.color
        cell.onUpdateTrackersDoneStatus = {[weak self] in
            guard let self else { return }
            
            if isTrackerCompleteOnCurrentDate(tracker.id) {
                self.dataProvider?.removeTrackerRecord(trackerID: tracker.id, date: self.currentDate)
            } else {
                self.dataProvider?.addTrackerRecord(trackerID: tracker.id, date: self.currentDate)
            }
            
            self.trackersCollection.reloadData()
        }
        
        if isTrackerCompleteOnCurrentDate(tracker.id) {
            cell.addButton.backgroundColor = tracker.color.withAlphaComponent(0.5)
            cell.addButton.isSelected = true
        } else {
            cell.addButton.backgroundColor = tracker.color
            cell.addButton.isSelected = false
        }
        
        // скрываем "+" для будущих дат
        cell.addButton.isHidden = Calendar.current.compare(Date(), to: currentDate, toGranularity: .day) == .orderedAscending
        
        return cell
    }
    
    // размеры ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - collectionParams.paddingWidth
        let cellWidth =  availableWidth / CGFloat(collectionParams.cellCount)
        return CGSize(width: cellWidth, height: 140)
    }
    
    // вертикальный отступ ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        collectionParams.cellSpacing
    }
    
    // горизонтальные отступ ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        collectionParams.cellSpacing
    }
    
    // отступ от краёв
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: collectionParams.leftInset, bottom: 24, right: collectionParams.rightInset)
    }
    
    // настройка хедера
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var id: String
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            id = "header"
        default:
            id = ""
        }
        
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: id, for: indexPath) as! SupplementaryView
        // текст заголовка
        guard let tracker = dataProvider?.object(at: indexPath) else { return view }
        view.titleLabel.text = tracker.category
        view.titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        return view
    }
    
    // размер хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

// для управления SearchBar'ом
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterValue = searchText
        updateFilters()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        filterValue = ""
        updateFilters()
    }
}

// для настройки плейсхолдеров коллекции трекеров
extension TrackersViewController {
    func setBGViewToCollection(_ collectionView: UICollectionView, imageName: String, text: String) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
        ])
        
        collectionView.backgroundView = view;
    }
}

extension TrackersViewController: DataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        trackersCollection.reloadData()
    }
}

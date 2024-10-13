import UIKit

var testCategories: [TrackerCategory] = [
    TrackerCategory(title: "Домашний уют", trackers: [
        Tracker(id: "0", name: "Поливать растения", color: .ypColorSelection18, emoji: "🪴", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
    ]),
    TrackerCategory(title: "Радостные мелочи", trackers: [
        Tracker(id: "1", name: "Кошка заслонила камеру на созвоне", color: .ypColorSelection2, emoji: "🐈", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
        Tracker(id: "2", name: "Бабушка прислала открытку в вотсапе", color: .ypColorSelection6, emoji: "🌺", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
        Tracker(id: "3", name: "Свидания в апреле", color: .ypColorSelection15, emoji: "🍆", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
    ]),
    TrackerCategory(title: "Самочувствие", trackers: [
        Tracker(id: "4", name: "Хорошее настроение", color: .ypColorSelection14, emoji: "🙂", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
        Tracker(id: "5", name: "Тревожность", color: .ypColorSelection1, emoji: "😱", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
    ]),
]

var testCompletedTrackers: [TrackerRecord] = [
    TrackerRecord(trackerID: "0", date: Date()),
    TrackerRecord(trackerID: "1", date: Date()),
    TrackerRecord(trackerID: "1", date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!),
]

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
    private var categories: [TrackerCategory] = testCategories // []
    private var completedTrackers: [TrackerRecord] = testCompletedTrackers // []
    private let collectionParams = GeometricParams(cellCount: 2, leftInset: 0, rightInset: 0, cellSpacing: 9)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchBarController
        
        if isNoTrackers() {
            // если нет трекеров, то показываем плейсхолдер
            view.addSubview(emptyTrackersImageView)
            view.addSubview(emptyTrackersTextLabel)
            
            NSLayoutConstraint.activate([
                emptyTrackersImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                emptyTrackersImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
                emptyTrackersImageView.widthAnchor.constraint(equalToConstant: 80),
                emptyTrackersImageView.heightAnchor.constraint(equalToConstant: 80),
                
                emptyTrackersTextLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
                emptyTrackersTextLabel.topAnchor.constraint(equalTo: emptyTrackersImageView.bottomAnchor, constant: 8),
            ])
        } else {
            // если трекеры есть, то показываем их
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
    }
    
    // проверяет, есть ли вообще трекеры
    private func isNoTrackers() -> Bool {
        let trackersCount = categories.reduce(0) { $0 + $1.trackers.count }
        return trackersCount == 0
    }
    
    // проверяет, отмечен ли трекер как выполненный в текущую дату
    private func isTrackerDone(_ trackerID: String) -> Bool {
        return completedTrackers.contains(where: { $0.trackerID == trackerID && Calendar.current.isDate($0.date, inSameDayAs: currentDate) })
    }
    
    // возвращает строку с кол-вом дней, в который трекер выполнялся
    private func getTrackerDaysLabelText(_ indexPath: IndexPath) -> String {
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        let days = completedTrackers.count(where: { $0.trackerID == tracker.id })
        
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
        //  проверяем, есть ли категория в списке
        if categories.contains(where: { $0.title == categoryName }) {
            categories = categories.map { $0.title == categoryName ? TrackerCategory(title: $0.title, trackers: $0.trackers + [tracker]) : $0 }
        } else {
            categories.insert(TrackerCategory(title: categoryName, trackers: [tracker]), at: 0)
        }
        trackersCollection.reloadData()
    }
    
    // отмечает трекер как выполненный в текущую дату
    @objc private func updateTrackersDoneStatus(_ trackerID: String, _ isAdding: Bool) {
        if isAdding {
            completedTrackers.append(TrackerRecord(trackerID: trackerID, date: currentDate))
        } else {
            completedTrackers = completedTrackers.filter { $0.trackerID != trackerID || !Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
        }
        
        trackersCollection.reloadData()
    }
    
    // обновление текущей даты
    @objc private func dateChanged() {
        currentDate = datePicker.date
        trackersCollection.reloadData()
    }
    
    // добавление нового трекера
    @objc private func addTapped() {
        present(UINavigationController(rootViewController: ChooseCreateTrackerViewController(onAddTracker: addTracker)), animated: true, completion: nil)
    }
}

// UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    // количество категорий
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    // количество ячеек в каждой категории
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    // настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionCell.identifier, for: indexPath) as! TrackerCollectionCell
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        cell.textLabel.text = tracker.name
        cell.infoLabel.text = getTrackerDaysLabelText(indexPath)
        cell.cardView.backgroundColor = tracker.color
        cell.onUpdateTrackersDoneStatus = self.updateTrackersDoneStatus
        cell.emojiLabel.text = tracker.emoji
        cell.addButton.accessibilityValue = tracker.id
        
        if isTrackerDone(tracker.id) {
            cell.addButton.backgroundColor = tracker.color.withAlphaComponent(0.5)
            cell.addButton.isSelected = true
        } else {
            cell.addButton.backgroundColor = tracker.color
            cell.addButton.isSelected = false
        }
        
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
        view.titleLabel.text = categories[indexPath.section].title
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

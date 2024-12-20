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
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()
    
    private lazy var searchBarController: UISearchController = {
        let searchBarController = UISearchController(searchResultsController: nil)
        searchBarController.searchBar.placeholder = NSLocalizedString("trackers.searchBar.placeholder", comment: "Поиск")
        searchBarController.searchBar.delegate = self
        return searchBarController
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.alwaysBounceVertical = true
        scroll.backgroundColor = .clear
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.backgroundColor = .clear
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
        collection.backgroundColor = .clear
        return collection
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle(NSLocalizedString("trackers.filters", comment: "Фильтры"), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.borderWidth = 0
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.backgroundColor = .ypBlue
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(openFilters), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentDate = Date()
    private var searchFilterValue: String = ""
    private var generalFilterValue: GeneralFilter = .all
    private var doneFilterValue: Bool? = nil
    private let collectionParams = GeometricParams(cellCount: 2, leftInset: 0, rightInset: 0, cellSpacing: 9)
    private let analyticsService = AnalyticsService()
    
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
        
        navigationItem.title = NSLocalizedString("trackers.title", comment: "Трекеры")
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = searchBarController
        
        mainStackView.addArrangedSubview(trackersCollection)
        scrollView.addSubview(mainStackView)
        view.addSubview(scrollView)
        view.addSubview(filtersButton)
        
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
            
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        analyticsService.report(event: "open", params: ["screen" : "Main"])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        analyticsService.report(event: "close", params: ["screen" : "Main"])
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
        return String.localizedStringWithFormat(
            NSLocalizedString("daysTracked", comment: "Number of days tracked"),
            days
        )
    }
    
    // добавляет новый трекер в коллекцию
    private func addTracker(_ tracker: Tracker) {
        searchBarController.searchBar.text = ""
        try? dataProvider?.addRecord(tracker)
    }
    
    private func editTracker(_ tracker: Tracker) {
        searchBarController.searchBar.text = ""
        dataProvider?.editTracker(tracker)
    }
    
    func updateFilters() {
        dataProvider?.filterTrackers(date: currentDate, searchFilter: searchFilterValue, doneFilter: doneFilterValue)
        trackersCollection.reloadData()
        
        filtersButton.layer.borderWidth = (generalFilterValue == .all) ? 0 : 2
    }
    
    func onGeneralFilterSelect(_ filter: GeneralFilter) {
        generalFilterValue = filter
        switch filter {
        case .all:
            doneFilterValue = nil
        case .today:
            currentDate = Date()
            datePicker.date = Date()
            doneFilterValue = nil
        case .done:
            doneFilterValue = true
        case .undone:
            doneFilterValue = false
        }
        updateFilters()
    }
    
    // обновление текущей даты
    @objc private func dateChanged() {
        currentDate = datePicker.date
        
        if currentDate != Date() && generalFilterValue == .today {
            generalFilterValue = .all
        }
        updateFilters()
    }
    
    // добавление нового трекера
    @objc private func addTapped() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "add_track"])
        present(UINavigationController(rootViewController: TrackerTypeSelectionViewController(onAddTracker: addTracker)), animated: true)
    }
    
    // выбор фильтра
    @objc private func openFilters() {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "filter"])
        present(
            UINavigationController(
                rootViewController: GeneralFiltersViewController(
                    selectedFilter: generalFilterValue,
                    onFilterSelect: onGeneralFilterSelect
                )),
            animated: true
        )
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
                setBGViewToCollection(
                    trackersCollection,
                    imageName: "trackers-placeholder",
                    text: NSLocalizedString("trackers.emptyTrackers", comment: "Что будем отслеживать?")
                )
            } else {
                setBGViewToCollection(
                    trackersCollection,
                    imageName: "no-trackers-found",
                    text: NSLocalizedString("trackers.noTrackersFound", comment: "Ничего не найдено")
                )
            }
            filtersButton.isHidden = true
        } else {
            trackersCollection.backgroundView = nil
            filtersButton.isHidden = false
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
        cell.pinImage.isHidden = !tracker.isPinned
        cell.textLabel.text = tracker.name
        cell.infoLabel.text = getTrackerDaysLabelText(for: tracker)
        cell.cardView.backgroundColor = tracker.color
        cell.onUpdateTrackersDoneStatus = {[weak self] in
            guard let self else { return }
            
            self.analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "track"])
            
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
        guard let tracker = dataProvider?.object(at: IndexPath(item: 0, section: indexPath.section)) else { return view }
        view.titleLabel.text = tracker.computedCategory
        view.titleLabel.font = .systemFont(ofSize: 19, weight: .bold)
        return view
    }
    
    // размер хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.frame.width, height: 24)
    }
}

// для управления SearchBar'ом
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchFilterValue = searchText
        updateFilters()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchFilterValue = ""
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

extension TrackersViewController: UICollectionViewDelegate {
    // контекстное меню
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPaths: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        guard let tracker = dataProvider?.object(at: indexPaths) else { return nil }
        let indexPathStr = NSString(string: "\(indexPaths.item), \(indexPaths.section)")
        
        let pinActionTitle = tracker.isPinned
        ? NSLocalizedString("trackers.contextMenu.unpin", comment: "Закрепить")
        : NSLocalizedString("trackers.contextMenu.pin", comment: "Открепить")
        let editActionTitle = NSLocalizedString("trackers.contextMenu.edit", comment: "Редактировать")
        let removeActionTitle = NSLocalizedString("trackers.contextMenu.remove", comment: "Удалить")
        
        return UIContextMenuConfiguration(identifier: indexPathStr, actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: pinActionTitle) { [weak self] _ in
                    self?.togglePinTrackerAction(tracker)
                },
                UIAction(title: editActionTitle) { [weak self] _ in
                    self?.editTrackerAction(tracker)
                },
                UIAction(title: removeActionTitle, attributes: .destructive) { [weak self] _ in
                    self?.removeTrackerAction(tracker)
                },
            ])
        })
    }
    
    // настройка превью при выделении
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        
        guard let identifier = configuration.identifier as? String,
              let item = Int(identifier.components(separatedBy: ", ")[0]),
              let section = Int(identifier.components(separatedBy: ", ")[1]),
              let cell = collectionView.cellForItem(at: IndexPath(item: item, section: section)) as? TrackerCollectionCell
        else { return nil }
        
        return UITargetedPreview(view: cell.cardView)
    }
    
    func togglePinTrackerAction(_ tracker: Tracker) {
        dataProvider?.pinTracker(tracker.id, setTo: !tracker.isPinned)
    }
    func editTrackerAction(_ tracker: Tracker) {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "edit"])
        
        present(UINavigationController(rootViewController: TrackerCreationViewController(
            onCreateTracker: self.editTracker,
            isRegular: !tracker.schedule.isEmpty,
            initialValues: tracker,
            daysTrackedLabelText: getTrackerDaysLabelText(for: tracker)
        )), animated: true)
    }
    func removeTrackerAction(_ tracker: Tracker) {
        analyticsService.report(event: "click", params: ["screen" : "Main", "item" : "delete"])
        
        let modalTitleText = NSLocalizedString("trackers.contextMenu.remove.modal.title", comment: "Уверены, что хотите удалить трекер?")
        let modalOkText = NSLocalizedString("trackers.contextMenu.remove.modal.ok", comment: "Удалить")
        let modalCancelText = NSLocalizedString("trackers.contextMenu.remove.modal.cancel", comment: "Отменить")
        
        let alert = UIAlertController(title: modalTitleText, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: modalOkText, style: .destructive, handler: { [weak self] _ in
            self?.dataProvider?.removeTracker(tracker.id)
        }))
        alert.addAction(UIAlertAction(title: modalCancelText, style: .cancel, handler: { _ in }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

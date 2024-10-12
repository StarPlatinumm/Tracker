import UIKit

class TrackersViewController: UIViewController {
    
    //    private lazy var dateFormatter: DateFormatter = {
    //        let formatter = DateFormatter()
    //        formatter.dateFormat = "d.MM.yy"
    //        return formatter
    //    }()
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
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        scroll.backgroundColor = .green
        return scroll
    }()
    
    private lazy var trackersCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(TrackerCollectionCell.self, forCellWithReuseIdentifier: TrackerCollectionCell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.backgroundColor = .brown
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
    
    private var categories: [TrackerCategory] = [
        TrackerCategory(title: "Спорт", trackers: [
            Tracker(id: 0, name: "Test", color: .ypColorSelection4, emoji: "🍆", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]),
            Tracker(id: 1, name: "Test2", color: .ypColorSelection4, emoji: "🍑", schedule: [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday])
        ]),
    ]
    private var completedTrackers: [TrackerRecord] = [
        // TrackerRecord(trackerID: 0, date: Date()),
    ]
    
    private let params = GeometricParams(cellCount: 6,
                                         leftInset: 8,
                                         rightInset: 8,
                                         cellSpacing: 6)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = UISearchController(searchResultsController: nil)
        
        if isNoTrackers() {
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
            scrollView.addSubview(trackersCollection)
            view.addSubview(scrollView)
            
            NSLayoutConstraint.activate([
                scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                
                trackersCollection.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
                trackersCollection.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
                trackersCollection.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
                trackersCollection.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
                trackersCollection.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            ])
        }
    }
    
    private func isNoTrackers() -> Bool {
        let trackersCount = categories.reduce(0) { $0 + $1.trackers.count }
        return trackersCount == 0
    }
    
    @objc private func dateChanged() {
        currentDate = datePicker.date
    }
    
    @objc private func addTapped() {
        present(UINavigationController(rootViewController: ChooseCreateTrackerViewController()), animated: true, completion: nil)
    }
}

// UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TrackerCell", for: indexPath)
        cell.backgroundColor = .orange
        return cell
    }
    
    // для хедера
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
        return view
    }
    
    // размеры ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        print("availableWidth: ", availableWidth)
        print("cellWidth: ", cellWidth)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // вертикальный отступ ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    // горизонтальные отступ ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    // отступ от краёв
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: params.leftInset, bottom: 24, right: params.rightInset)
    }
    
    // для хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}

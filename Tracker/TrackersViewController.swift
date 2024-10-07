import UIKit

class TrackersViewController: UIViewController {
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yy"
        return formatter
    }()
    
    
    private var emptyTrackersImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    
    private var emptyTrackersTextLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.locale = Locale(identifier: "ru_RU")
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        addButton.tintColor = UIColor.ypBlack
        
        navigationItem.title = "Трекеры"
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
        navigationItem.searchController = UISearchController(searchResultsController: nil)
    }
    
    @objc func addTapped() {
        present(UINavigationController(rootViewController: ChooseCreateTrackerViewController()), animated: true, completion: nil)
    }
    
    
    private func addEmptyTrackersImageView() {
        view.addSubview(emptyTrackersImageView)
        emptyTrackersImageView.image = UIImage(named: "trackers-placeholder")
        emptyTrackersImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        emptyTrackersImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        emptyTrackersImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        emptyTrackersImageView.heightAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    private func addEmptyTrackersTextLabel() {
        view.addSubview(emptyTrackersTextLabel)
        emptyTrackersTextLabel.text = "Что будем отслеживать?"
        emptyTrackersTextLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
        emptyTrackersTextLabel.topAnchor.constraint(equalTo: emptyTrackersImageView.bottomAnchor, constant: 8).isActive = true
    }
}

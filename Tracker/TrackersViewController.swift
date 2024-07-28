import UIKit

class TrackersViewController: UIViewController {
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.MM.yy"
        return formatter
    }()
    
    private var plusButton: UIButton  = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "add-tracker-button"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var currentDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.backgroundColor = .ypLightGray
        label.layer.cornerRadius = 8
        label.layer.masksToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var roundedRectangleView: UIView = {
        let view = UIView(frame: CGRect(x: 50, y: 50, width: 200, height: 100))
        view.backgroundColor = .ypLightGray
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var headerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPlusButton()
        addCurrentDateLabel()
        addHeaderLabel()
        addSearchBar()
        addEmptyTrackersImageView()
        addEmptyTrackersTextLabel()
        
    }
    
    private func addPlusButton() {
        view.addSubview(plusButton)
        plusButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 4).isActive = true
        plusButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
    }
    
    private func addCurrentDateLabel() {
        view.addSubview(currentDateLabel)
        currentDateLabel.text = dateFormatter.string(from: Date())
        currentDateLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
        currentDateLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5).isActive = true
        currentDateLabel.widthAnchor.constraint(equalToConstant: 77).isActive = true
        currentDateLabel.heightAnchor.constraint(equalToConstant: 34).isActive = true
    }
    
    private func addHeaderLabel() {
        view.addSubview(headerLabel)
        headerLabel.text = "Трекеры"
        headerLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        headerLabel.topAnchor.constraint(equalTo: plusButton.bottomAnchor).isActive = true
    }
    
    private func addSearchBar() {
        view.addSubview(searchBar)
        searchBar.placeholder = "Поиск"
        searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8).isActive = true
        searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8).isActive = true
        searchBar.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 7).isActive = true
        searchBar.heightAnchor.constraint(equalToConstant: 36).isActive = true
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

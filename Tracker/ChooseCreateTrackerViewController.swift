import UIKit

// экран выбора создания привычки или нерегулярного события
final class ChooseCreateTrackerViewController: UIViewController {
    
    private let onAddTracker: (Tracker, String) -> Void
    
    init(onAddTracker: @escaping (Tracker, String) -> Void) {
        self.onAddTracker = onAddTracker
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        self.title = "Создание трекера"
        
        let regularEventButton = getButton("Привычка")
        regularEventButton.addTarget(self, action: #selector(opencCreateTrackerWithSchedule), for: .touchUpInside)
        let irregularEventButton = getButton("Нерегулярное событие")
        irregularEventButton.addTarget(self, action: #selector(opencCreateTrackerWOSchedule), for: .touchUpInside)
        
        view.addSubview(regularEventButton)
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            regularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            regularEventButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            regularEventButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            regularEventButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            regularEventButton.heightAnchor.constraint(equalToConstant: 60),
            
            irregularEventButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            irregularEventButton.topAnchor.constraint(equalTo: regularEventButton.bottomAnchor, constant: 16),
            irregularEventButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            irregularEventButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func getButton(_ title: String) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    @objc private func opencCreateTrackerWithSchedule() {
        navigationController?.pushViewController(TrackerTypeSelectionViewController(onCreateTracker: self.onAddTracker, isRegular: true), animated: true)
    }
    
    @objc private func opencCreateTrackerWOSchedule() {
        navigationController?.pushViewController(TrackerTypeSelectionViewController(onCreateTracker: self.onAddTracker, isRegular: false), animated: true)
    }
}

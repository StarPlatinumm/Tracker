
import UIKit

final class ScheduleViewController: UIViewController {
    private var schedule: [Weekday]
    private let updateSchedule: ([Weekday]) -> Void
    private let tableOptions: [Weekday] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(schedule: [Weekday], updateSchedule: @escaping ([Weekday]) -> Void) {
        self.schedule = schedule
        self.updateSchedule = updateSchedule
        
        super.init(nibName: nil, bundle: nil)
    }
    
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
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(ScheduleTableCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var doneButtonView: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlack
        button.isEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Расписание"
        navigationItem.hidesBackButton = true
        
        view.backgroundColor = .white
        
        // выбор категории и расписания
        mainStackView.addArrangedSubview(tableView)
        
        // кнопка "Готово"
        mainStackView.addArrangedSubview(doneButtonView)
        
        scrollView.addSubview(mainStackView)
        view.addSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            mainStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            mainStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            tableView.heightAnchor.constraint(equalToConstant: 530),
            doneButtonView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func createSwitchView(id: Int) -> UISwitch {
        let switchView = UISwitch()
        switchView.isOn = schedule.contains(tableOptions[id])
        switchView.onTintColor = .ypBlue
        switchView.tag = id
        switchView.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        return switchView
    }
    
    @objc func switchValueChanged(switchView: UISwitch) {
        if switchView.isOn {
            // добавляем позицию в расписание
            if !schedule.contains(tableOptions[switchView.tag]) {
                schedule.append(tableOptions[switchView.tag])
            }
        } else {
            // удаляем позицию из расписания
            if let index = schedule.firstIndex(of: tableOptions[switchView.tag]) {
                schedule.remove(at: index)
            }
        }
    }
    
    @objc func doneButtonTapped() {
        self.updateSchedule(self.schedule)
        navigationController?.popViewController(animated: true)
    }
}

// TableViewDataSource Protocol
extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ScheduleTableCell
        cell.textLabel?.text = self.tableOptions[indexPath.row].rawValue
        
        let switchView = createSwitchView(id: indexPath.row)
        cell.accessoryView = switchView
        return cell
    }
}

// TableViewDelegate Protocol
extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

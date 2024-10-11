
import UIKit

struct tableOption {
    let title: String
    var subtitle: String = ""
    let vc: UIViewController.Type
}

final class CreateTrackerViewController: UIViewController {
    
    private let colorCollectionViewController = Collection6x3ViewController(type: .color)
    private let emojiCollectionViewController = Collection6x3ViewController(type: .emoji)
    
    private var warningHeightConstraint: NSLayoutConstraint?
    
    var schedule: [Weekday] = []
    var tableOptions: [tableOption] = []
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(isRegular: Bool) {
        self.tableOptions.append(tableOption(title: "Категория", vc: ChooseCreateTrackerViewController.self))
        if isRegular {
            // если событие регулярное (привычка), то добавляем в меню пункт "Расписание"
            self.tableOptions.append(tableOption(title: "Расписание", vc: SetScheduleViewController.self))
        }
        
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
    
    private lazy var nameTextField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypLightGray
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var longNameWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .ypRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CustomTableCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var emojiCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(Collection6x3Cell.self, forCellWithReuseIdentifier: Collection6x3Cell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self.emojiCollectionViewController
        collection.delegate = self.emojiCollectionViewController
        return collection
    }()
    
    private lazy var colorCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(Collection6x3Cell.self, forCellWithReuseIdentifier: Collection6x3Cell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self.colorCollectionViewController
        collection.delegate = self.colorCollectionViewController
        return collection
    }()
    
    private lazy var createButtonView: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlack
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButtonView: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(.ypRed, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1.0
        button.layer.borderColor = UIColor.ypRed.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Новая привычка"
        navigationItem.hidesBackButton = true
        
        view.backgroundColor = .white
        
        // название трекера
        let nameStackView = UIStackView(arrangedSubviews: [nameTextField, longNameWarningLabel])
        nameStackView.axis = .vertical
        nameStackView.spacing = 8
        mainStackView.addArrangedSubview(nameStackView)
        
        // выбор категории и расписания
        mainStackView.addArrangedSubview(tableView)
        
        // выбор emoji
        mainStackView.addArrangedSubview(emojiCollection)
        
        // выбор цвета
        mainStackView.addArrangedSubview(colorCollection)
        
        // кнопки снизу
        let buttonsStackView = UIStackView(arrangedSubviews: [cancelButtonView, createButtonView])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        mainStackView.addArrangedSubview(buttonsStackView)
        
        scrollView.addSubview(mainStackView) // добавляем на экран скролл вью
        view.addSubview(scrollView)          // в скролл вью добавляем стек со всеми элементами
        
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
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            tableView.heightAnchor.constraint(equalToConstant: 160),
            emojiCollection.heightAnchor.constraint(equalToConstant: 240),
            colorCollection.heightAnchor.constraint(equalToConstant: 240),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    func onUpdateSchedule(_ schedule: [Weekday]) {
        self.schedule = schedule
        self.tableOptions[1].subtitle = schedule.map { item in
            switch item {
            case .monday: return "Пн"
            case .tuesday: return "Вт"
            case .wednesday: return "Ср"
            case .thursday: return "Чт"
            case .friday: return "Пт"
            case .saturday: return "Сб"
            case .sunday: return "Вс"
            }
        }.joined(separator: ", ")
        self.tableView.reloadData()
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // проверка на длину поля с именем
        if let length = textField.text?.count {
            longNameWarningLabel.isHidden = length <= 38
            view.layoutIfNeeded()
        }
    }
}

// TableViewDataSource Protocol
extension CreateTrackerViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableCell
        cell.textLabel?.text = self.tableOptions[indexPath.row].title
        cell.detailTextLabel?.text = self.tableOptions[indexPath.row].subtitle
        return cell
    }
}

// TableViewDelegate Protocol
extension CreateTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = self.tableOptions[indexPath.row].title
        if selected == "Категория" {
            // переход в выбор категории
            navigationController?.pushViewController(
                ChooseCreateTrackerViewController(),
                animated: true
            )
        } else if selected == "Расписание" {
            // переход в выбор расписания
            navigationController?.pushViewController(
                SetScheduleViewController(schedule: self.schedule, updateSchedule: self.onUpdateSchedule),
                animated: true
            )
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}


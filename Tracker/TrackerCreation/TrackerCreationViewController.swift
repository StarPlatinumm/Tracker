
import UIKit

struct tableOption {
    let title: String
    var subtitle: String = ""
    let vc: UIViewController.Type
}

struct CollectionSectionsContent {
    let title: String
    let elements: [Any]
}

// экран создания нового трекера
final class TrackerCreationViewController: UIViewController {
    
    private let onCreateTracker: (Tracker, String) -> Void
    private let isRegular: Bool
    
    private let collectionParams = GeometricParams(cellCount: 6, leftInset: 8, rightInset: 8, cellSpacing: 6)
    private let collectionContent: [CollectionSectionsContent] = [
        .init(title: "Emoji", elements: ["🪴", "🧋", "🦭", "📍", "👀", "🎉",
                                         "🌭", "🪽", "🐌", "🌵", "⚡️", "❤️",
                                         "🎲", "✨", "🎈", "💰", "🐞", "⭐️"]),
        .init(title: "Цвет", elements: (1...18).compactMap { UIColor(named: "ypColorSelection\($0)") })
    ]
    
    private var trackerName: String = ""
    private var category: TrackerCategory = TrackerCategory(title: "Новые", trackers: [])
    private var schedule: [Weekday] = []
    private var selectedEmoji: IndexPath? = nil
    private var selectedColor: IndexPath? = nil
    private var tableOptions: [tableOption] = []
    
    private let weekdaysText = ["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"]
    
    init(onCreateTracker: @escaping (Tracker, String) -> Void, isRegular: Bool) {
        self.onCreateTracker = onCreateTracker
        self.isRegular = isRegular
        
        self.tableOptions.append(tableOption(title: "Категория", subtitle: category.title, vc: TrackerTypeSelectionViewController.self))
        if isRegular {
            // если событие регулярное (привычка), то добавляем в меню пункт "Расписание"
            self.tableOptions.append(tableOption(title: "Расписание", vc: ScheduleViewController.self))
        }
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
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
    
    private lazy var emojiAndColorCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(EmojiCollectionCell.self, forCellWithReuseIdentifier: EmojiCollectionCell.identifier)
        collection.register(ColorCollectionCell.self, forCellWithReuseIdentifier: ColorCollectionCell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        collection.dataSource = self
        collection.delegate = self
        collection.isScrollEnabled = false
        collection.allowsMultipleSelection = true
        return collection
    }()
    
    private lazy var createButtonView: UIButton = {
        let button = CustomButton(type: .custom)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.setBackgroundColor(.ypBlack, for: .normal)
        button.setBackgroundColor(.ypGray, for: .disabled)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
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
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
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
        
        // выбор emoji и цвета
        mainStackView.addArrangedSubview(emojiAndColorCollection)
        
        // кнопки снизу
        let buttonsStackView = UIStackView(arrangedSubviews: [cancelButtonView, createButtonView])
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        mainStackView.addArrangedSubview(buttonsStackView)
        
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
            
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            tableView.heightAnchor.constraint(equalToConstant: self.isRegular ? 151 : 76),
            emojiAndColorCollection.heightAnchor.constraint(equalToConstant: 460),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func onUpdateSchedule(_ schedule: [Weekday]) {
        self.schedule = schedule
        if schedule.count == 7 {
            self.tableOptions[1].subtitle = "Каждый день"
        } else {
            self.tableOptions[1].subtitle = schedule.map { weekdaysText[$0.rawValue]}.joined(separator: ", ")
        }
        self.tableView.reloadData()
        self.updateCreateButtonState()
    }
    
    // блокирует/разблокирует кнопку "Создать"
    private func updateCreateButtonState() {
        createButtonView.isEnabled =
            !self.trackerName.isEmpty &&
            (!self.schedule.isEmpty || !isRegular) &&
            self.selectedColor != nil &&
            self.selectedEmoji != nil
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // проверка на длину поля с именем
        if let length = textField.text?.count {
            longNameWarningLabel.isHidden = length <= 38
            view.layoutIfNeeded()
        }
        
        if longNameWarningLabel.isHidden {
            self.trackerName = textField.text ?? ""
        } else {
            self.trackerName = ""
        }
        
        self.updateCreateButtonState()
    }
    
    @objc func cancelButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func createButtonTapped() {
        guard let trackerEmoji = collectionContent.first(where: { $0.title == "Emoji" })?.elements[selectedEmoji?.row ?? 0] as? String,
              let trackerColor = collectionContent.first(where: { $0.title == "Цвет" })?.elements[selectedColor?.row ?? 0] as? UIColor
        else { return }
        
        self.onCreateTracker(
            Tracker(id: "", name: self.trackerName, color: trackerColor, emoji: trackerEmoji, schedule: self.schedule),
            self.category.title
        )
        
        // возвращаемся на экран со списком трекеров
        if let viewControllers = navigationController?.viewControllers {
            for vc in viewControllers {
                vc.dismiss(animated: true)
            }
        }
    }
}

// TableViewDataSource Protocol
extension TrackerCreationViewController: UITableViewDataSource {
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
extension TrackerCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = self.tableOptions[indexPath.row].title
        if selected == "Категория" {
            // переход в выбор категории
        } else if selected == "Расписание" {
            // переход в выбор расписания
            navigationController?.pushViewController(
                ScheduleViewController(schedule: self.schedule, updateSchedule: self.onUpdateSchedule),
                animated: true
            )
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// работа с коллекцией
extension TrackerCreationViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // количество категорий
    func numberOfSections(in collectionView: UICollectionView) -> Int { collectionContent.count }
    
    // кол-во элементов в секции
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int { collectionContent[section].elements.count }
    
    // настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section = collectionContent[indexPath.section]

        if section.title == "Emoji" {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.identifier, for: indexPath) as? EmojiCollectionCell else {
                return UICollectionViewCell()
            }
            
            cell.prepareForReuse()
            
            // вписываем эмодзи
            guard let emoji = section.elements[indexPath.row] as? String else { return cell }
            cell.setEmoji(emoji)
            
            return cell
        } else if section.title == "Цвет" {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCell.identifier, for: indexPath) as? ColorCollectionCell else {
                return UICollectionViewCell()
            }
            
            cell.prepareForReuse()
            
            // задаём цвет
            guard let color = section.elements[indexPath.row] as? UIColor else { return cell }
            cell.setColor(color)
            
            return cell
        }
        
        return UICollectionViewCell()
    }
    
    // размеры ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - collectionParams.paddingWidth
        let cellWidth =  availableWidth / CGFloat(collectionParams.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
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
    
    // для хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
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
        view.titleLabel.text = collectionContent[indexPath.section].title
        return view
    }
    
    // выделение ячейки
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let section = collectionContent[indexPath.section]

        if section.title == "Emoji" {
            // снимает выделение с предыдущей ячейки (если есть)
            if let selectedEmoji {
                guard let cell = collectionView.cellForItem(at: selectedEmoji) as? EmojiCollectionCell else { return }
                cell.didSelect(false)
                self.selectedEmoji = nil
            }
            // выделяем ячейку
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionCell else { return }
            cell.didSelect(true)
            self.selectedEmoji = indexPath
        } else if section.title == "Цвет" {
            // снимает выделение с предыдущей ячейки (если есть)
            if let selectedColor {
                guard let cell = collectionView.cellForItem(at: selectedColor) as? ColorCollectionCell else { return }
                cell.didSelect(false)
                self.selectedColor = nil
            }
            // выделяем ячейку
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorCollectionCell else { return }
            cell.didSelect(true)
            self.selectedColor = indexPath
        }

        self.updateCreateButtonState()
    }
}

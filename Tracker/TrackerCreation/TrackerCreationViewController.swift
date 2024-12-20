
import UIKit

struct tableOption {
    let title: String
    var subtitle: String = ""
    let vc: UIViewController.Type
}

struct CollectionSectionsContent {
    let title: String
    let elements: [String]
}

// экран создания нового трекера
final class TrackerCreationViewController: UIViewController {
    
    private let onCreateTracker: (Tracker) -> Void
    private let isRegular: Bool
    
    private let collectionParams = GeometricParams(cellCount: 6, leftInset: 8, rightInset: 8, cellSpacing: 6)
    private lazy var collectionContent: [CollectionSectionsContent] = [
        .init(title: NSLocalizedString("trackerCreation.emoji", comment: "Emoji"), elements: [
            "🪴", "🧋", "🦭", "📍", "👀", "🎉",
            "🌭", "🪽", "🐌", "🌵", "⚡️", "❤️",
            "🎲", "✨", "🎈", "💰", "🐞", "⭐️"
        ]),
        .init(title: NSLocalizedString("trackerCreation.color", comment: "Цвет"), elements: (1...18).compactMap { "ypColorSelection\($0)" })
    ]
    
    private var trackerName: String = ""
    private var category: String = ""
    private var schedule: [Weekday] = []
    private var selectedEmoji: IndexPath? = nil
    private var selectedColor: IndexPath? = nil
    private var tableOptions: [tableOption] = []
    private var daysTrackedLabelText: String = ""
    private var initialValues: Tracker? = nil
    
    private let weekdaysText = [
        NSLocalizedString("trackerCreation.weekdays.mon", comment: "Пн"),
        NSLocalizedString("trackerCreation.weekdays.tue", comment: "Вт"),
        NSLocalizedString("trackerCreation.weekdays.wed", comment: "Ср"),
        NSLocalizedString("trackerCreation.weekdays.thu", comment: "Чт"),
        NSLocalizedString("trackerCreation.weekdays.fri", comment: "Пт"),
        NSLocalizedString("trackerCreation.weekdays.sat", comment: "Сб"),
        NSLocalizedString("trackerCreation.weekdays.sun", comment: "Вс")
    ]
    
    init(onCreateTracker: @escaping (Tracker) -> Void, isRegular: Bool, initialValues: Tracker? = nil, daysTrackedLabelText: String = "") {
        self.onCreateTracker = onCreateTracker
        self.isRegular = isRegular
        self.initialValues = initialValues
        self.daysTrackedLabelText = daysTrackedLabelText
        
        self.tableOptions.append(tableOption(title: NSLocalizedString("trackerCreation.category", comment: "Категория"), vc: TrackerTypeSelectionViewController.self))
        if isRegular {
            // если событие регулярное (привычка), то добавляем в меню пункт "Расписание"
            self.tableOptions.append(tableOption(title: NSLocalizedString("trackerCreation.schedule", comment: "Расписание"), vc: ScheduleViewController.self))
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
    
    private lazy var daysTrackedLabel: UILabel = {
        let label = UILabel()
        label.text = daysTrackedLabelText
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.isHidden = daysTrackedLabelText.isEmpty
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameTextField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.placeholder = NSLocalizedString("trackerCreation.nameTextField.placeholder", comment: "Введите название трекера")
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
        label.text = NSLocalizedString("trackerCreation.nameTextField.maxLen", comment: "Ограничение 38 символов")
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
        button.setTitle(NSLocalizedString("trackerCreation.saveButton", comment: "Создать"), for: .normal)
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
        button.setTitle(NSLocalizedString("trackerCreation.cancelButton", comment: "Отменить"), for: .normal)
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
        
        
        self.title = NSLocalizedString(
            "trackerCreation.title.\(initialValues == nil ? "create" :"edit").\(isRegular ? "regular" : "irregular")",
            comment: "Title"
        )
        navigationItem.hidesBackButton = true
        
        view.backgroundColor = .ypWhite
        
        // заполняем данные
        if let initialValues {
            trackerName = initialValues.name
            category = initialValues.category
            schedule = initialValues.schedule
            selectedEmoji = getEmojiIndexPath(initialValues.emoji)
            selectedColor = getColorIndexPath(initialValues.color)
            
            nameTextField.text = trackerName
            onReturnCategory(category)
            onUpdateSchedule(schedule)
        }
        
        mainStackView.addArrangedSubview(daysTrackedLabel)
        
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
            emojiAndColorCollection.heightAnchor.constraint(equalToConstant: 470),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView(emojiAndColorCollection, didSelectItemAt: selectedEmoji ?? IndexPath(item: 0, section: 0))
        collectionView(emojiAndColorCollection, didSelectItemAt: selectedColor ?? IndexPath(item: 0, section: 1))
    }
    
    private func onUpdateSchedule(_ schedule: [Weekday]) {
        self.schedule = schedule
        if schedule.count == 7 {
            tableOptions[1].subtitle = NSLocalizedString("trackerCreation.schedule.everyDay", comment: "Каждый день")
        } else {
            tableOptions[1].subtitle = schedule.map { weekdaysText[$0.rawValue]}.joined(separator: ", ")
        }
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    private func onReturnCategory(_ category: String) {
        self.category = category
        tableOptions[0].subtitle = category
        
        tableView.reloadData()
        updateCreateButtonState()
    }
    
    private func getEmojiIndexPath(_ emoji: String) -> IndexPath {
        for (index, value) in collectionContent[0].elements.enumerated() {
            if emoji == value {
                return IndexPath(row: index, section: 0)
            }
        }
        return IndexPath(row: 0, section: 0)
    }
    
    private func getColorIndexPath(_ color: UIColor) -> IndexPath {
        let hexColor1 = UIColorMarshalling().hexString(from: color)
        
        for (index, value) in collectionContent[1].elements.enumerated() {
            guard let namedColor = UIColor(named: value) else { continue }
            let hexColor2 = UIColorMarshalling().hexString(from: namedColor)
            if hexColor1 == hexColor2 {
                return IndexPath(row: index, section: 1)
            }
        }
        return IndexPath(row: 0, section: 1)
    }
    
    // блокирует/разблокирует кнопку "Создать"
    private func updateCreateButtonState() {
        createButtonView.isEnabled =
        !self.trackerName.isEmpty &&
        !self.category.isEmpty &&
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
        let trackerEmoji = collectionContent[0].elements[selectedEmoji?.row ?? 0]
        let trackerColor = UIColor(named: collectionContent[1].elements[selectedColor?.row ?? 0]) ?? .ypGray
        
        self.onCreateTracker(
            Tracker(id: initialValues?.id ?? "", name: self.trackerName, color: trackerColor, emoji: trackerEmoji, schedule: self.schedule, category: self.category, computedCategory: "", isPinned: false)
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
        if selected == NSLocalizedString("trackerCreation.category", comment: "Категория") {
            // переход в выбор категории
            navigationController?.pushViewController(
                CategoryViewController(selectedCategory: self.category, returnCategory: self.onReturnCategory),
                animated: true
            )
        } else if selected == NSLocalizedString("trackerCreation.schedule", comment: "Расписание") {
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
        
        if section.title == NSLocalizedString("trackerCreation.emoji", comment: "Emoji") {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionCell.identifier, for: indexPath) as? EmojiCollectionCell else {
                return UICollectionViewCell()
            }
            
            cell.prepareForReuse()
            
            // вписываем эмодзи
            let emoji = section.elements[indexPath.row]
            cell.setEmoji(emoji)
            
            return cell
        } else if section.title == NSLocalizedString("trackerCreation.color", comment: "Цвет") {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionCell.identifier, for: indexPath) as? ColorCollectionCell else {
                return UICollectionViewCell()
            }
            
            cell.prepareForReuse()
            
            // задаём цвет
            let color = UIColor(named: section.elements[indexPath.row]) ?? .ypGray
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
    
    // размер хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 24)
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
        
        if section.title == NSLocalizedString("trackerCreation.emoji", comment: "Emoji") {
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
        } else if section.title == NSLocalizedString("trackerCreation.color", comment: "Цвет") {
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

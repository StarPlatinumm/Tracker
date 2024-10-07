
import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private let hasSchedule: Bool
    
    private var optionsTableViewController: OptionsWithVCTableViewController
    private let colorCollectionViewController = Collection6x3ViewController(type: .color)
    private let emojiCollectionViewController = Collection6x3ViewController(type: .emoji)
    
    private var warningHeightConstraint: NSLayoutConstraint?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(hasSchedule: Bool) {
        self.hasSchedule = hasSchedule
        
        var tableOptions: [OptionWithRedirect] = []
        tableOptions.append(OptionWithRedirect(label: "Категория", vc: ChooseCreateTrackerViewController.self))
        if hasSchedule {
            tableOptions.append(OptionWithRedirect(label: "Расписание", vc: ChooseCreateTrackerViewController.self))
        }
        self.optionsTableViewController = OptionsWithVCTableViewController(options: tableOptions)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    let nameTextField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypLightGray
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let longNameWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .ypRed
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    let emojiCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        // Регистрируем ячейку в коллекции.
        collection.register(Collection6x3Cell.self, forCellWithReuseIdentifier: Collection6x3Cell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    let colorCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        // Регистрируем ячейку в коллекции.
        collection.register(Collection6x3Cell.self, forCellWithReuseIdentifier: Collection6x3Cell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Новая привычка"
        navigationItem.hidesBackButton = true
        
        view.backgroundColor = .white
        
        // название трекера
        view.addSubview(nameTextField)
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        // предупреждение о слишком длинном названии трекера
        view.addSubview(longNameWarningLabel)
        
        // выбор категории и расписания
        addChild(optionsTableViewController)
        view.addSubview(optionsTableViewController.view)
        optionsTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        optionsTableViewController.didMove(toParent: self)
        
        // выбор emoji
        view.addSubview(emojiCollection)
        emojiCollection.dataSource = self.emojiCollectionViewController
        emojiCollection.delegate = self.emojiCollectionViewController
        
        // выбор цвета
        view.addSubview(colorCollection)
        colorCollection.dataSource = self.colorCollectionViewController
        colorCollection.delegate = self.colorCollectionViewController
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            nameTextField.bottomAnchor.constraint(equalTo: nameTextField.topAnchor, constant: 75),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            longNameWarningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8),
            longNameWarningLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            longNameWarningLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            optionsTableViewController.view.topAnchor.constraint(equalTo: longNameWarningLabel.bottomAnchor, constant: 10),
            optionsTableViewController.view.bottomAnchor.constraint(equalTo: optionsTableViewController.view.topAnchor, constant: 160),
            optionsTableViewController.view.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            optionsTableViewController.view.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            emojiCollection.topAnchor.constraint(equalTo: optionsTableViewController.view.bottomAnchor, constant: 10),
            emojiCollection.bottomAnchor.constraint(equalTo: emojiCollection.topAnchor, constant: 250),
            emojiCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            emojiCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            colorCollection.topAnchor.constraint(equalTo: emojiCollection.bottomAnchor, constant: 10),
            colorCollection.bottomAnchor.constraint(equalTo: colorCollection.topAnchor, constant: 250),
            colorCollection.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            colorCollection.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
        
        // отдельно задаём высоту предупреждения о длине имени, чтобы потом изменять
        self.warningHeightConstraint = longNameWarningLabel.bottomAnchor.constraint(equalTo: longNameWarningLabel.topAnchor, constant: 0)
        self.warningHeightConstraint?.isActive = true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let length = textField.text?.count {
            if length > 3 {
                self.warningHeightConstraint?.constant = 22
                view.layoutIfNeeded()
            } else {
                self.warningHeightConstraint?.constant = 0
                view.layoutIfNeeded()
            }
        }
    }
}

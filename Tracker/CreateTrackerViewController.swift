
import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private let isRegular: Bool
    
    private var optionsTableViewController: OptionsWithVCTableViewController
    private let colorCollectionViewController = Collection6x3ViewController(type: .color)
    private let emojiCollectionViewController = Collection6x3ViewController(type: .emoji)
    
    private var warningHeightConstraint: NSLayoutConstraint?
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(isRegular: Bool) {
        self.isRegular = isRegular
        
        var tableOptions: [OptionWithRedirect] = []
        tableOptions.append(OptionWithRedirect(label: "Категория", vc: ChooseCreateTrackerViewController.self))
        if isRegular {
            tableOptions.append(OptionWithRedirect(label: "Расписание", vc: ChooseCreateTrackerViewController.self))
        }
        self.optionsTableViewController = OptionsWithVCTableViewController(options: tableOptions)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    private let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 24
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let nameTextField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.placeholder = "Введите название трекера"
        textField.font = UIFont.systemFont(ofSize: 17)
        textField.layer.cornerRadius = 16
        textField.backgroundColor = .ypLightGray
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let longNameWarningLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .ypRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emojiCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(Collection6x3Cell.self, forCellWithReuseIdentifier: Collection6x3Cell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let colorCollection: UICollectionView = {
        let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collection.register(Collection6x3Cell.self, forCellWithReuseIdentifier: Collection6x3Cell.identifier)
        collection.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "header")
        collection.translatesAutoresizingMaskIntoConstraints = false
        return collection
    }()
    
    private let createButtonView: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlack
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let cancelButtonView: UIButton = {
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
        nameTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        mainStackView.addArrangedSubview(nameStackView)
        
        // выбор категории и расписания
        addChild(optionsTableViewController)
        optionsTableViewController.view.translatesAutoresizingMaskIntoConstraints = false
        optionsTableViewController.didMove(toParent: self)
        mainStackView.addArrangedSubview(optionsTableViewController.view)
        
        // выбор emoji
        emojiCollection.dataSource = self.emojiCollectionViewController
        emojiCollection.delegate = self.emojiCollectionViewController
        mainStackView.addArrangedSubview(emojiCollection)
        
        // выбор цвета
        colorCollection.dataSource = self.colorCollectionViewController
        colorCollection.delegate = self.colorCollectionViewController
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
            optionsTableViewController.view.heightAnchor.constraint(equalToConstant: 160),
            emojiCollection.heightAnchor.constraint(equalToConstant: 240),
            colorCollection.heightAnchor.constraint(equalToConstant: 240),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // проверка на длину поля с именем
        if let length = textField.text?.count {
            longNameWarningLabel.isHidden = length <= 38
            view.layoutIfNeeded()
        }
    }
}

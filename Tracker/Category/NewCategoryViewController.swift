
import UIKit

// экран добавления новой категории
final class NewCategoryViewController: UIViewController {
    
    private var categoryName: String = ""
    private var updateCategories: ((String) -> Void)
    
    init(updateCategories: @escaping (String) -> Void) {
        self.updateCategories = updateCategories
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    private lazy var nameTextField: UITextField = {
        let textField = TextFieldWithPadding()
        textField.placeholder = NSLocalizedString("newCategory.nameTextField.placeholder", comment: "Введите название категории")
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
        label.text = NSLocalizedString("newCategory.nameTextField.maxLen", comment: "Ограничение 24 символа")
        label.font = UIFont.systemFont(ofSize: 17)
        label.textAlignment = .center
        label.textColor = .ypRed
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneButtonView: UIButton = {
        let button = CustomButton(type: .custom)
        button.setTitle(NSLocalizedString("newCategory.doneButton.text", comment: "Готово"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.setBackgroundColor(.ypBlack, for: .normal)
        button.setBackgroundColor(.ypGray, for: .disabled)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("newCategory.title", comment: "Новая категория")
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        
        view.addSubview(nameTextField)
        view.addSubview(longNameWarningLabel)
        view.addSubview(doneButtonView)
        
        NSLayoutConstraint.activate([
            nameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            nameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            longNameWarningLabel.topAnchor.constraint(equalTo: nameTextField.bottomAnchor),
            longNameWarningLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            longNameWarningLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            longNameWarningLabel.heightAnchor.constraint(equalToConstant: 60),
            
            doneButtonView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            doneButtonView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            doneButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButtonView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    // блокирует/разблокирует кнопку "Готово"
    private func updateDoneButtonState() {
        doneButtonView.isEnabled = !categoryName.isEmpty
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        // проверка на длину поля с именем
        if let length = textField.text?.count {
            longNameWarningLabel.isHidden = length <= 24
        }
        
        if longNameWarningLabel.isHidden {
            self.categoryName = textField.text ?? ""
        } else {
            self.categoryName = ""
        }
        
        self.updateDoneButtonState()
    }
    
    @objc func createButtonTapped() {
        updateCategories(categoryName)
        // возвращаемся
        navigationController?.popViewController(animated: true)
    }
}

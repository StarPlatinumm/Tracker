
import UIKit

final class CategoryViewController: UIViewController {
    
    private var selectedCategory: String
    
    private var vm = CategoryViewModel()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    init(selectedCategory: String, returnCategory: @escaping ((String) -> Void)) {
        self.selectedCategory = selectedCategory
        
        super.init(nibName: nil, bundle: nil)
        bind(returnCategory)
    }
    
    private func bind(_ returnCategory: @escaping ((String) -> Void)) {
        vm.returnCategory = { category in
            returnCategory(category)
        }
        
        vm.updateCategories = { [weak self] _ in
            self?.tableView.reloadData()
        }
    }
    
    private lazy var scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(CategoryTableCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var newCategoryButtonView: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(NSLocalizedString("category.newCategoryButton.text", comment: "Добавить категорию"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlack
        button.isEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(newCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("category.title", comment: "Добавить категорию")
        navigationItem.hidesBackButton = true
        view.backgroundColor = .ypWhite
        
        vm.getCategories()
        
        mainStackView.addArrangedSubview(tableView)
        
        mainStackView.addArrangedSubview(newCategoryButtonView)
        
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
            
            tableView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: -92),
            
            newCategoryButtonView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor , constant: -16),
            newCategoryButtonView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func newCategoryButtonTapped() {
        navigationController?.pushViewController(
            NewCategoryViewController(updateCategories: vm.addNewCategory),
            animated: true
        )
    }
}

// TableViewDataSource Protocol
extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (vm.categories.count == 0) {
            setBGViewToTable(imageName: "trackers-placeholder", text: NSLocalizedString("category.table.placeholer", comment: "Привычки и события можно объединить по смыслу"))
        } else {
            tableView.backgroundView = nil
        }
    
        return vm.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CategoryTableCell
        cell.textLabel?.text = vm.categories[indexPath.row]
        
        let accessoryView = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        accessoryView.font = .systemFont(ofSize: 20, weight: .medium)
        accessoryView.text = vm.categories[indexPath.row] == selectedCategory ? "✓" : ""
        accessoryView.textColor = .ypBlue
        cell.accessoryView = accessoryView
        
        return cell
    }
}

// TableViewDelegate Protocol
extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        vm.pickCategory(indexPath.row)
        navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

// для настройки плейсхолдеров таблицы с категориями
extension CategoryViewController {
    func setBGViewToTable(imageName: String, text: String) {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: imageName)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = text
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            label.widthAnchor.constraint(equalToConstant: 200),
        ])
        
        tableView.backgroundView = view;
    }
}

extension CategoryViewController: DataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        // stub
    }
}

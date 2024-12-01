import UIKit


final class GeneralFiltersViewController: UIViewController {
    
    private var selectedFilter: GeneralFilter
    private var onFilterSelect: ((GeneralFilter) -> Void)
    
    init(selectedFilter: GeneralFilter, onFilterSelect: @escaping ((GeneralFilter) -> Void)) {
        self.selectedFilter = selectedFilter
        self.onFilterSelect = onFilterSelect
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var tableView: UITableView = {
        let table = UITableView()
        table.register(GeneralFiltersTableCell.self, forCellReuseIdentifier: "cell")
        table.delegate = self
        table.dataSource = self
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Категория"
        navigationItem.hidesBackButton = true
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
}

// TableViewDataSource Protocol
extension GeneralFiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 4 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! GeneralFiltersTableCell
        cell.textLabel?.text = GeneralFilter.allCases[indexPath.row].rawValue
        
        let accessoryView = UILabel(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
        accessoryView.font = .systemFont(ofSize: 20, weight: .medium)
        accessoryView.text = GeneralFilter.allCases[indexPath.row].rawValue == selectedFilter.rawValue ? "✓" : ""
        accessoryView.textColor = .ypBlue
        cell.accessoryView = accessoryView
        
        return cell
    }
}

// TableViewDelegate Protocol
extension GeneralFiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        onFilterSelect(GeneralFilter.allCases[indexPath.row])
        navigationController?.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

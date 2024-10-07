import UIKit

struct OptionWithRedirect {
    let label: String
    let vc: UIViewController.Type
}
class OptionsWithVCTableViewController: UITableViewController {
    
    var options: [OptionWithRedirect] = []
    
    init(options: [OptionWithRedirect]) {
        self.options = options
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(CustomOptionsTableCell.self, forCellReuseIdentifier: "cell")
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomOptionsTableCell
        cell.textLabel?.text = options[indexPath.row].label
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedOption = options[indexPath.row]
        let selectedVC = selectedOption.vc.init()
        navigationController?.pushViewController(selectedVC, animated: true)
    }
}



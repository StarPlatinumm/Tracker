import UIKit

class CustomOptionsTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .ypLightGray
        
        layer.masksToBounds = true
        layer.cornerRadius = 16
        
        translatesAutoresizingMaskIntoConstraints = false
        
        // Add disclosure indicator
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Round corners based on position in the table
        if let indexPath = (superview as? UITableView)?.indexPath(for: self) {
            if indexPath.row == 0 {
                // First cell
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == (superview as! UITableView).numberOfRows(inSection: indexPath.section) - 1 {
                // Last cell
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
            } else {
                // Middle cells
                layer.maskedCorners = []
            }
        }
    }
}

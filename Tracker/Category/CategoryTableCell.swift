import UIKit

final class CategoryTableCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .ypLightGray
        
        layer.masksToBounds = true
        layer.cornerRadius = 16
        
        translatesAutoresizingMaskIntoConstraints = false
        
        separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Скругляем углы ячейкам в зависимости от их позиции в таблице
        if let indexPath = (superview as? UITableView)?.indexPath(for: self) {
            if (superview as! UITableView).numberOfRows(inSection: indexPath.section) == 1 {
                // если строчка только одна (скругляем полностью)
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
            } else if indexPath.row == 0 {
                // первая строчка (скругляем сверху)
                layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            } else if indexPath.row == (superview as! UITableView).numberOfRows(inSection: indexPath.section) - 1 {
                // последняя строчка (скругляем снизу)
                layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: CGFloat.greatestFiniteMagnitude)
            } else {
                // строчки в середине
                layer.maskedCorners = []
            }
        }
    }
}

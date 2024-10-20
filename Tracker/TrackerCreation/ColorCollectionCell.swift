import UIKit

final class ColorCollectionCell: UICollectionViewCell {
    
    // Идентификатор ячейки — используется для регистрации и восстановления:
    static let identifier = "ColorCell"
    
    private lazy var overlay: UIView = {
        let view = UIView(frame: CGRect(x: 6, y: 6, width: contentView.frame.width - 12, height: contentView.frame.height - 12))
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    // Конструктор:
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // Закруглим края для ячейки:
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        
        // рамка
        contentView.layer.borderWidth = 0
        
        contentView.addSubview(overlay)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setColor(_ color: UIColor) {
        overlay.backgroundColor = color
        contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
    }
    
    func didSelect(_ value: Bool) {
        contentView.layer.borderWidth = value ? 3 : 0
    }
}

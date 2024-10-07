import UIKit

enum Collection6x3Type {
    case emoji
    case color
}

final class Collection6x3ViewController: NSObject, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    private let collectionType: Collection6x3Type
    private let colors: [UIColor] = (1...18).compactMap { UIColor(named: "ypColorSelection\($0)") }
    private let emoji: [String] = ["🪴", "🧋", "🦭", "📍", "👀", "🎉",
                                   "🌭", "🪽", "🐌", "🌵", "⚡️", "❤️",
                                   "🎲", "✨", "🎈", "💰", "🐞", "⭐️"]
    private let params = GeometricParams(cellCount: 6,
                                         leftInset: 8,
                                         rightInset: 8,
                                         cellSpacing: 6)
    
    init(type: Collection6x3Type) {
        self.collectionType = type
    }
    
    // длина коллекции
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        // возвращаем длину массива colors или emoji соответственно
        return self.collectionType == .emoji ? emoji.count : colors.count
    }
    
    // настройка ячейки
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Collection6x3Cell.identifier, for: indexPath) as? Collection6x3Cell else {
            return UICollectionViewCell()
        }
        
        cell.prepareForReuse()
        
        // вписываем эмодзи и задаём цвет
        switch self.collectionType {
        case .color:
            cell.textLabel.text = ""
            cell.contentView.backgroundColor = colors[indexPath.row]
        case .emoji:
            cell.textLabel.text = emoji[indexPath.row]
            cell.contentView.backgroundColor = .clear
        }
        
        return cell
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
        view.titleLabel.text = self.collectionType == .emoji ? "Emoji" : "Цвет"
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    // размеры ячейки
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth =  availableWidth / CGFloat(params.cellCount)
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    // вертикальный отступ ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    // горизонтальные отступ ячеек
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        params.cellSpacing
    }
    
    // отступ от краёв
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 24, left: params.leftInset, bottom: 24, right: params.rightInset)
    }
    
    // для хедера
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let indexPath = IndexPath(row: 0, section: section)
        let headerView = self.collectionView(collectionView, viewForSupplementaryElementOfKind: UICollectionView.elementKindSectionHeader, at: indexPath)
        
        return headerView.systemLayoutSizeFitting(CGSize(width: collectionView.frame.width,
                                                         height: UIView.layoutFittingExpandedSize.height),
                                                  withHorizontalFittingPriority: .required,
                                                  verticalFittingPriority: .fittingSizeLevel)
    }
}


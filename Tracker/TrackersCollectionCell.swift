import UIKit

class TrackerCollectionCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"

    let cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = .blue
        return view
    }()

    let emojiLabel: UILabel = {
        let label = UILabel()
        label.text = "😊"
        label.textAlignment = .center
        label.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        return label
    }()

    let textLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample Text"
        label.textAlignment = .center
        return label
    }()

    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "Info"
        label.textAlignment = .left
        return label
    }()

    let addButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.backgroundColor = .green
        button.layer.cornerRadius = 10
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(textLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(addButton)

        // Add constraints here
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        // Layout subviews here
    }

}

import UIKit

// ячейка трекера
final class TrackerCollectionCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    
    var onUpdateTrackersDoneStatus: ((String, Bool) -> Void)? = nil

    lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textAlignment = .center
        label.backgroundColor = .ypWhite.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypWhite
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setTitle("+", for: .normal)
        button.setTitle("✓", for: .selected)
        button.layer.cornerRadius = 17
        button.addTarget(self, action: #selector(onAddButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(cardView)
        cardView.addSubview(emojiLabel)
        cardView.addSubview(textLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(addButton)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            cardView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            
            textLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            textLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            textLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -12),
            
            infoLabel.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 16),
            infoLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 12),
            
            addButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -12),
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func onAddButtonTapped(_ button: UIButton) {
        button.isSelected.toggle()
        self.onUpdateTrackersDoneStatus?(button.accessibilityValue ?? "", button.isSelected)
    }
}

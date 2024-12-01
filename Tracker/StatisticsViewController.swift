import UIKit


final class StatisticsViewController: UIViewController {
    
    private lazy var dataProvider: DataProviderProtocol? = {
        do {
            try dataProvider = DataProvider(delegate: self)
            return dataProvider
        } catch {
            print("Данные недоступны")
            return nil
        }
    }()
    
    private var doneCount = 0
    
    private lazy var cardView: UIView = {
        let card = UIView()
        card.backgroundColor = UIColor.clear
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        
        let titleLabel = UILabel()
        titleLabel.text = String(doneCount)
        titleLabel.font = .systemFont(ofSize: 34, weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(titleLabel)
        
        let subtitleLabel = UILabel()
        subtitleLabel.text = NSLocalizedString("statistics.doneCount", comment: "Трекеров завершено")
        subtitleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        subtitleLabel.textAlignment = .left
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(subtitleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            titleLabel.heightAnchor.constraint(equalToConstant: 41),
            titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            subtitleLabel.heightAnchor.constraint(equalToConstant: 18),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
        ])
        
        card.translatesAutoresizingMaskIntoConstraints = false

        return card
    }()
    
    private lazy var noDataPlaceholder: UIView = {
        let placeholder = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no-statistics")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        placeholder.addSubview(imageView)
        
        let label = UILabel()
        label.text = NSLocalizedString("statistics.empty", comment: "Анализировать пока нечего")
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        placeholder.addSubview(label)
        
        placeholder.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: placeholder.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: placeholder.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
        ])
        
        return placeholder
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("statistics.title", comment: "Статистика")
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        doneCount = dataProvider?.getAllTrackersRecordsCount() ?? 0
        
        if doneCount > 0 {
            view.addSubview(cardView)
            
            NSLayoutConstraint.activate([
                cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                cardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
                cardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
                cardView.heightAnchor.constraint(equalToConstant: 90),
            ])
        } else {
            view.addSubview(noDataPlaceholder)
            
            NSLayoutConstraint.activate([
                noDataPlaceholder.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                noDataPlaceholder.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            ])
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let gradient = CAGradientLayer()
        gradient.frame = cardView.bounds
        gradient.colors = [UIColor.ypColorSelection1.cgColor, UIColor.ypColorSelection5.cgColor, UIColor.ypColorSelection3.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.path = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: cardView.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        cardView.layer.addSublayer(gradient)
    }
}

extension StatisticsViewController: DataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        // stub
    }
}

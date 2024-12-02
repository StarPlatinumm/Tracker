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
    
    private lazy var doneTitleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.doneCount", comment: "Трекеров завершено")
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneCountLabel: UILabel = {
        let label = UILabel()
        label.text = String(doneCount)
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var doneCardView: UIView = {
        let card = UIView()
        card.backgroundColor = UIColor.clear
        card.layer.cornerRadius = 16
        card.clipsToBounds = true
        card.isHidden = true
        card.translatesAutoresizingMaskIntoConstraints = false
        return card
    }()
    
    private lazy var noDataImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no-statistics")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var noDataLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("statistics.empty", comment: "Анализировать пока нечего")
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var noDataView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = NSLocalizedString("statistics.title", comment: "Статистика")
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        
        layoutViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateStatistics()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let gradient = CAGradientLayer()
        gradient.frame = doneCardView.bounds
        gradient.colors = [UIColor.ypColorSelection1.cgColor, UIColor.ypColorSelection5.cgColor, UIColor.ypColorSelection3.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.path = UIBezierPath(roundedRect: doneCardView.bounds, cornerRadius: doneCardView.layer.cornerRadius).cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        gradient.mask = shape

        doneCardView.layer.addSublayer(gradient)
    }
    
    private func layoutViews() {
        view.addSubview(doneCardView)
        doneCardView.addSubview(doneCountLabel)
        doneCardView.addSubview(doneTitleLabel)
        
        NSLayoutConstraint.activate([
            doneCardView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            doneCardView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            doneCardView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            doneCardView.heightAnchor.constraint(equalToConstant: 90),
            
            doneCountLabel.topAnchor.constraint(equalTo: doneCardView.topAnchor, constant: 12),
            doneCountLabel.heightAnchor.constraint(equalToConstant: 41),
            doneCountLabel.leadingAnchor.constraint(equalTo: doneCardView.leadingAnchor, constant: 12),
            doneCountLabel.trailingAnchor.constraint(equalTo: doneCardView.trailingAnchor, constant: -12),
            
            doneTitleLabel.topAnchor.constraint(equalTo: doneCountLabel.bottomAnchor, constant: 7),
            doneTitleLabel.heightAnchor.constraint(equalToConstant: 18),
            doneTitleLabel.leadingAnchor.constraint(equalTo: doneCountLabel.leadingAnchor),
            doneTitleLabel.trailingAnchor.constraint(equalTo: doneCountLabel.trailingAnchor),
        ])
        
        view.addSubview(noDataView)
        noDataView.addSubview(noDataImage)
        noDataView.addSubview(noDataLabel)
        
        NSLayoutConstraint.activate([
            noDataView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noDataView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            noDataImage.centerXAnchor.constraint(equalTo: noDataView.centerXAnchor),
            noDataImage.centerYAnchor.constraint(equalTo: noDataView.centerYAnchor),
            noDataImage.widthAnchor.constraint(equalToConstant: 80),
            noDataImage.heightAnchor.constraint(equalToConstant: 80),
            
            noDataLabel.centerXAnchor.constraint(equalTo: noDataImage.centerXAnchor),
            noDataLabel.topAnchor.constraint(equalTo: noDataImage.bottomAnchor, constant: 8),
        ])
    }
    
    private func updateStatistics() {
        doneCount = dataProvider?.getAllTrackersRecordsCount() ?? 0
        
        if doneCount > 0 {
            doneCountLabel.text = "\(doneCount)"
            doneCardView.isHidden = false
            noDataView.isHidden = true
        } else {
            doneCardView.isHidden = true
            noDataView.isHidden = false
        }
    }
}

extension StatisticsViewController: DataProviderDelegate {
    func didUpdate(_ update: TrackerStoreUpdate) {
        // stub
    }
}

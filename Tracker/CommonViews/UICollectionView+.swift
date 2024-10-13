import UIKit

extension UICollectionView {
    
    // когда не добавлено ни одного рекера
    func setEmptyTrackers() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "trackers-placeholder")
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
        ])
        
        self.backgroundView = view;
    }
    
    // когда после фильтрации не осталось ни одного трекера
    func setNoTrackersFound() {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        
        let imageView = UIImageView()
        imageView.image = UIImage(named: "no-trackers-found")
        imageView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel()
        label.text = "Ничего не найдено"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(imageView)
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
        ])
        
        self.backgroundView = view;
    }

    // возвращаемся в обычное состояние
    func restore() {
        self.backgroundView = nil
    }
}

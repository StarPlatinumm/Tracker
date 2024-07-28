import UIKit

class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        // вкладка Трекеры
        let trackerViewController = TrackersViewController()
        trackerViewController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(named: "trackers-tab-bar-icon"),
            selectedImage: nil
        )
        
        // вкладка Статистика
        let statisticsViewController = UIViewController()
        statisticsViewController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(named: "statistics-tab-bar-icon"),
            selectedImage: nil
        )
        
        viewControllers = [trackerViewController, statisticsViewController]
    }
    
}


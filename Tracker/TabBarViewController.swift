import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        
        // вкладка Трекеры
        let trackerViewController = UINavigationController(rootViewController: TrackersViewController())
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBar.trackers.title", comment: "Трекеры"),
            image: UIImage(named: "trackers-tab-bar-icon"),
            selectedImage: nil
        )
        
        // вкладка Статистика
        let statisticsViewController = UINavigationController(rootViewController: StatisticsViewController())
        statisticsViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tabBar.statistics.title", comment: "Статистика"),
            image: UIImage(named: "statistics-tab-bar-icon"),
            selectedImage: nil
        )
        
        viewControllers = [trackerViewController, statisticsViewController]
    }
    
}


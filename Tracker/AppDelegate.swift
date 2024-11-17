import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        
        if false /*UserDefaults.standard.bool(forKey: "hasSeenOnboarding")*/ {
            window?.rootViewController = TabBarViewController()
        } else {
            window?.rootViewController = OnboardingViewController(transitionStyle: .scroll, navigationOrientation: .horizontal) as UIPageViewController
        }

        window?.makeKeyAndVisible()
        
        return true
    }
}

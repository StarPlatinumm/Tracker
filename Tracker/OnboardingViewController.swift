import UIKit

class OnboardingViewController: UIPageViewController {
    
    lazy var continueButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private func getBigBlackLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    private func getPage(backgroundImageName: String, labelText: String) -> UIViewController {
        let page = UIViewController()
        if let backgroundImage = UIImage(named: backgroundImageName) {
            let backgroundView = UIImageView(frame: UIScreen.main.bounds)
            backgroundView.image = backgroundImage
            backgroundView.contentMode = .scaleAspectFill
            
            let label = getBigBlackLabel(labelText)
            
            page.view.addSubview(backgroundView)
            page.view.addSubview(label)
            
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: page.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: page.view.centerYAnchor, constant: 60),
                label.leftAnchor.constraint(equalTo: page.view.leftAnchor, constant: 20),
                label.rightAnchor.constraint(equalTo: page.view.rightAnchor, constant: -20),
            ])
        }
        return page
    }
    
    lazy var pages: [UIViewController] = {
        return [
            getPage(backgroundImageName: "onboarding_page_1", labelText: "Отслеживайте только то, что хотите"),
            getPage(backgroundImageName: "onboarding_page_2", labelText: "Даже если это не литры воды и йога")
        ]
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.pageIndicatorTintColor = .ypGray
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        
        view.addSubview(pageControl)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150),
            
            continueButton.topAnchor.constraint(equalTo: pageControl.bottomAnchor, constant: 24),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20),
            continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc func continueButtonTapped() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
        let window = appDelegate.window else { return }
        
        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
            window.rootViewController = TabBarViewController()
        }, completion: nil)
        
        window.rootViewController = TabBarViewController()
    }
}


extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < pages.count else {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}

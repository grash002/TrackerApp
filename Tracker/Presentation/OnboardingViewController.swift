import UIKit

final class OnboardingViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate{
    
    // MARK: - Private Properties
    private lazy var pages: [UIViewController] = {
        lazy var titleLabelFirst: UILabel = {
            let label = UILabel()
            label.text = "Отслеживайте только то, что хотите"
            label.font = .boldSystemFont(ofSize: 32)
            label.textColor = .black
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            firstView.view.addSubview(label)
            return label
        }()
        
        lazy var titleLabelSecond: UILabel = {
            let label = UILabel()
            label.text = "Даже если это не литры воды и йога"
            label.font = .boldSystemFont(ofSize: 32)
            label.textColor = .black
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            secondView.view.addSubview(label)
            return label
        }()
        
        let firstView = UIViewController()
        let firstImageView = UIImageView(image: UIImage(named: "onboard1"))
        firstImageView.translatesAutoresizingMaskIntoConstraints = false
        firstView.view.addSubview(firstImageView)
        NSLayoutConstraint.activate([
            firstImageView.heightAnchor.constraint(equalTo: firstView.view.heightAnchor),
            firstImageView.widthAnchor.constraint(equalTo: firstView.view.widthAnchor),
            firstImageView.centerXAnchor.constraint(equalTo: firstView.view.centerXAnchor),
            firstImageView.centerYAnchor.constraint(equalTo: firstView.view.centerYAnchor),
            
            
            titleLabelFirst.topAnchor.constraint(equalTo: firstView.view.centerYAnchor),
            titleLabelFirst.leadingAnchor.constraint(equalTo: firstView.view.leadingAnchor, constant: 16),
            titleLabelFirst.trailingAnchor.constraint(equalTo: firstView.view.trailingAnchor, constant: -16),
        ])
        
        let secondView = UIViewController()
        let secondImageView = UIImageView(image: UIImage(named: "onboard2"))
        secondImageView.translatesAutoresizingMaskIntoConstraints = false
        secondView.view.addSubview(secondImageView)
        
        NSLayoutConstraint.activate([
            secondImageView.heightAnchor.constraint(equalTo: secondView.view.heightAnchor),
            secondImageView.widthAnchor.constraint(equalTo: secondView.view.widthAnchor),
            secondImageView.centerXAnchor.constraint(equalTo: secondView.view.centerXAnchor),
            secondImageView.centerYAnchor.constraint(equalTo: secondView.view.centerYAnchor),
            
            titleLabelSecond.topAnchor.constraint(equalTo: secondView.view.centerYAnchor),
            titleLabelSecond.leadingAnchor.constraint(equalTo: secondView.view.leadingAnchor, constant: 16),
            titleLabelSecond.trailingAnchor.constraint(equalTo: secondView.view.trailingAnchor, constant: -16),
        ])
        return [firstView, secondView]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = UIColor(named: "backGround")
        
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var onboardingButton: UIButton = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .black
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(buttonDidTap), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        return button
    }()
    

    // MARK: - Initializers
    override init(transitionStyle style: UIPageViewController.TransitionStyle,
                  navigationOrientation: UIPageViewController.NavigationOrientation,
                  options: [UIPageViewController.OptionsKey : Any]? = nil) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Overrides Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        
        if let first = pages.first {
            setViewControllers([first],
                               direction: .forward,
                               animated: true)
        }
        
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: onboardingButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            onboardingButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor,
                                                     constant: -50),
            onboardingButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor,
                                                     constant: -20),
            onboardingButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor,
                                                     constant: 20),
            onboardingButton.heightAnchor.constraint(equalToConstant: 60),
            
        ])
    }
    
    
    // MARK: - Public Methods
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let viewControllerIndexBefore = viewControllerIndex - 1
        
        guard viewControllerIndexBefore >= 0 else { return pages.last }
        
        return pages[viewControllerIndexBefore]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        let viewControllerIndexAfter = viewControllerIndex + 1
        
        guard viewControllerIndexAfter < pages.count else { return pages.first }
        
        return pages[viewControllerIndexAfter]
    }
    
    
    // MARK: - Private Methods
    @objc
    private func buttonDidTap() {
        let tabBarController = TabBarController()
        tabBarController.modalPresentationStyle = .fullScreen
        self.present(tabBarController, animated: true)
    }
}


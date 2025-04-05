import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let trackersViewController = TrackersViewController()
        trackersViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("tabBarView.trackerView.title", comment: ""),
                                                         image: UIImage(named: "TrackerTabBar"),
                                                         selectedImage: nil)
        
        let statisticViewController = StatisticViewController()
        
        statisticViewController.tabBarItem = UITabBarItem(title: NSLocalizedString("tabBarView.statisticView.title", comment: ""),
                                                          image: UIImage(named: "StatisticTabBar"),
                                                          selectedImage: nil)
        
        let topBorder = CALayer()
        topBorder.backgroundColor = UIColor.lightGray.cgColor
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.bounds.width, height: 1)
        tabBar.layer.addSublayer(topBorder)
        
        viewControllers = [trackersViewController,statisticViewController]
    }
}


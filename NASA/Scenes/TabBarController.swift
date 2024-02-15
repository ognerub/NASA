import UIKit

final class TabBarController: UITabBarController {
    private let mainTabBarItem = UITabBarItem(
        title: "Picture of Day",
        image: UIImage(systemName: "photo.on.rectangle.angled"),
        tag: 0
    )
    private let searchTabBarItem = UITabBarItem(
        title: "Search",
        image: UIImage(systemName: "magnifyingglass"),
        tag: 1
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mainViewController = UINavigationController(
            rootViewController:
                MainViewController(
                    currentCellIndex:
                        IndexPath(item: 0, section: 0)
                )
            )
        mainViewController.tabBarItem = mainTabBarItem
        
        let searchViewController = SearchViewController()
        searchViewController.tabBarItem = searchTabBarItem
        
        viewControllers = [
            mainViewController,
            searchViewController
        ]
        selectedIndex = 0
        
        view.backgroundColor = UIColor.clear
        tabBar.backgroundColor = UIColor.clear
        tabBar.tintColor = UIColor.white
        tabBar.unselectedItemTintColor = UIColor.gray
        
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .black
            self.tabBar.standardAppearance = appearance
            self.tabBar.scrollEdgeAppearance = appearance
        }
    }
}

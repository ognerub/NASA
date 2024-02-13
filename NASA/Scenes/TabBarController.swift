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

        let mainViewController = MainViewController()
        mainViewController.tabBarItem = mainTabBarItem
        
        let searchViewController = SearchViewController()
        searchViewController.tabBarItem = searchTabBarItem

        viewControllers = [
            mainViewController,
            searchViewController
        ]
        selectedIndex = 0

        view.backgroundColor = UIColor.black
        tabBar.backgroundColor = UIColor.black
        tabBar.tintColor = UIColor.white
        tabBar.unselectedItemTintColor = UIColor.gray
    }
}

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        let mainViewModel = MainViewControllerViewModel()
        let mainViewController = UINavigationController(
            rootViewController:
                MainViewController(
                    currentCellIndex:
                        IndexPath(item: 0, section: 0),
                    viewModel: mainViewModel
                )
            )
        window.rootViewController = mainViewController
        window.overrideUserInterfaceStyle = .dark
        self.window = window
        window.makeKeyAndVisible()
    }
}



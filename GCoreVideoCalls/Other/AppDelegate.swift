import UIKit

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let startVC = HomeViewController()

        let navController = UINavigationController(rootViewController: startVC)
        navController.navigationBar.tintColor = .white

        navController.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain,
            target: nil, action: nil
        )

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
        
        return true
    }
}


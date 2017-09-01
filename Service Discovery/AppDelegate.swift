
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = FirstViewController()
        let nc = UINavigationController(rootViewController: viewController)
        nc.navigationBar.backgroundColor = UIColor(red: 0.61, green: 0.80, blue: 0.89, alpha: 1.0)
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
        return true
    }

    func transitionView() {
        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor(red: 0.61, green: 0.80, blue: 0.89, alpha: 1.0)

        let tabViewController1 = BluetoothViewController()
        let tabViewController2 = BluetoothViewController() // drugi nacin
        tabViewController1.title = "Nearby Devices"
        tabViewController2.title = "Nesto Drugo"
        
        tabBarController.viewControllers = [UINavigationController(rootViewController:tabViewController1),  UINavigationController(rootViewController:tabViewController2)]

        let item1 = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.history, tag: 0)
        let item2 = UITabBarItem(tabBarSystemItem: UITabBarSystemItem.contacts, tag: 1)
        tabViewController1.tabBarItem = item1
        tabViewController2.tabBarItem = item2
        
        tabBarController.selectedIndex = 0
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
    }
}

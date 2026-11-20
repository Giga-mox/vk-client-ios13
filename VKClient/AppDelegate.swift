import UIKit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
              let url = userActivity.webpageURL,
              url.scheme == "https", url.host == "giga-mox.github.io",
              ["/api/vkclient/vk_id_redirect", "/api/vkclient/vk_id_redirect/"].contains(url.path)
        else { return false }
        // This is a routing test only. Do not read, log or exchange OAuth codes.
        DispatchQueue.main.async { [weak self] in
            guard let root = self?.window?.rootViewController else { return }
            let alert = UIAlertController(title: "Universal Link работает",
                                          message: "iOS передала ссылку в VK Client. Авторизация пока не подключена.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            root.present(alert, animated: true)
        }
        return true
    }
}

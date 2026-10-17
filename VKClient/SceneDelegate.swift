import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate, AuthViewControllerDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        self.window = window
        
        if VKAPIService.shared.isAuthenticated {
            window.rootViewController = TabBarController()
        } else {
            showAuth()
        }
        window.makeKeyAndVisible()
    }
    
    func showAuth() {
        let authVC = AuthViewController()
        authVC.delegate = self
        let nav = UINavigationController(rootViewController: authVC)
        window?.rootViewController = nav
    }
    
    func didAuthenticateSuccessfully() {
        window?.rootViewController = TabBarController()
    }
}

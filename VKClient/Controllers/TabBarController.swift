import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.tintColor = UIColor(red: 0.18, green: 0.52, blue: 0.92, alpha: 1.0)
        setupTabs()
    }
    
    private func setupTabs() {
        let feedVC = UINavigationController(rootViewController: FeedViewController())
        feedVC.tabBarItem = UITabBarItem(title: "Новости", image: UIImage(systemName: "newspaper"), tag: 0)
        
        let dialogsVC = UINavigationController(rootViewController: DialogsViewController())
        dialogsVC.tabBarItem = UITabBarItem(title: "Сообщения", image: UIImage(systemName: "bubble.left.and.bubble.right"), tag: 1)
        
        let friendsVC = UINavigationController(rootViewController: FriendsViewController())
        friendsVC.tabBarItem = UITabBarItem(title: "Друзья", image: UIImage(systemName: "person.2"), tag: 2)
        
        let profileVC = UINavigationController(rootViewController: ProfileViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Профиль", image: UIImage(systemName: "person.crop.circle"), tag: 3)
        
        viewControllers = [feedVC, dialogsVC, friendsVC, profileVC]
    }
}

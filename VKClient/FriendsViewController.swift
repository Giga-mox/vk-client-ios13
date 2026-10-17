import UIKit

final class FriendsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    private var friends: [VKUser] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Друзья"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        loadFriends()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(loadFriends), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func loadFriends() {
        VKAPIService.shared.getFriends { [weak self] result in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let resp):
                self.friends = resp.items
                self.tableView.reloadData()
            case .failure(let error):
                print("Ошибка друзей: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let friend = friends[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "FriendCell")
        cell.textLabel?.text = friend.fullName
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        let status = friend.isOnline ? "🟢 В сети" : (friend.status ?? "")
        cell.detailTextLabel?.text = status
        cell.detailTextLabel?.textColor = friend.isOnline ? UIColor.systemGreen : UIColor.secondaryLabel
        return cell
    }
}

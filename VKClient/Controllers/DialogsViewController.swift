import UIKit

final class DialogsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    
    private var conversations: [VKConversationItem] = []
    private var profiles: [Int: VKUser] = [:]
    private var groups: [Int: VKGroup] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Сообщения"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        loadConversations()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 72
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(loadConversations), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func loadConversations() {
        VKAPIService.shared.getConversations { [weak self] result in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let resp):
                self.conversations = resp.items
                if let profs = resp.profiles {
                    for p in profs { self.profiles[p.id] = p }
                }
                if let grps = resp.groups {
                    for g in grps { self.groups[g.id] = g }
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Ошибка сообщений: \(error)")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = conversations[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ConvCell")
        let peerId = item.conversation.peer.id
        
        var title = "Чат"
        if peerId > 0 {
            if let user = profiles[peerId] {
                title = user.fullName
            }
        } else {
            if let group = groups[-peerId] {
                title = group.name
            }
        }
        
        cell.textLabel?.text = title
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        
        let prefix = item.lastMessage.out == 1 ? "Вы: " : ""
        cell.detailTextLabel?.text = prefix + item.lastMessage.text
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = conversations[indexPath.row]
        let peerId = item.conversation.peer.id
        
        var peerTitle = "Диалог"
        if peerId > 0, let user = profiles[peerId] { peerTitle = user.fullName }
        else if let group = groups[-peerId] { peerTitle = group.name }
        
        let chatVC = ChatViewController(peerId: peerId, title: peerTitle)
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

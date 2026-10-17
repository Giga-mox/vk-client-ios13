import UIKit

final class FeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let refreshControl = UIRefreshControl()
    
    private var posts: [VKPost] = []
    private var profiles: [Int: VKUser] = [:]
    private var groups: [Int: VKGroup] = [:]
    private var isLoading = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новости"
        view.backgroundColor = .systemBackground
        
        setupTableView()
        loadFeed()
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        refreshControl.addTarget(self, action: #selector(refreshFeed), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    @objc private func refreshFeed() {
        loadFeed()
    }
    
    private func loadFeed() {
        guard !isLoading else { return }
        isLoading = true
        
        VKAPIService.shared.getNewsfeed { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            self.refreshControl.endRefreshing()
            
            switch result {
            case .success(let feed):
                self.posts = feed.items
                if let profs = feed.profiles {
                    for p in profs { self.profiles[p.id] = p }
                }
                if let grps = feed.groups {
                    for g in grps { self.groups[g.id] = g }
                }
                self.tableView.reloadData()
            case .failure(let error):
                print("Ошибка загрузки ленты: \(error)")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "PostCell")
        cell.selectionStyle = .none
        
        // Определение автора (пользователь или сообщество)
        var authorName = "Пользователь"
        if post.sourceId > 0 {
            if let user = profiles[post.sourceId] {
                authorName = user.fullName
            }
        } else {
            let groupId = -post.sourceId
            if let group = groups[groupId] {
                authorName = group.name
            }
        }
        
        let date = Date(timeIntervalSince1970: post.date)
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM в HH:mm"
        let dateString = formatter.string(from: date)
        
        let likesCount = post.likes?.count ?? 0
        let commentsCount = post.comments?.count ?? 0
        let stats = "❤️ \(likesCount)   💬 \(commentsCount)"
        
        cell.textLabel?.text = authorName
        cell.textLabel?.font = .systemFont(ofSize: 16, weight: .bold)
        
        var body = post.text
        if body.isEmpty, let attachments = post.attachments, !attachments.isEmpty {
            body = "[Прикрепленные материалы: \(attachments.count)]"
        }
        cell.detailTextLabel?.numberOfLines = 6
        cell.detailTextLabel?.font = .systemFont(ofSize: 14)
        cell.detailTextLabel?.text = "\(dateString)\n\n\(body)\n\n\(stats)"
        
        return cell
    }
}

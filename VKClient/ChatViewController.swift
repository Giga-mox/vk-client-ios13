import UIKit

final class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let peerId: Int
    private let peerTitle: String
    private var messages: [VKMessage] = []
    
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputContainer = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    init(peerId: Int, title: String) {
        self.peerId = peerId
        self.peerTitle = title
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = peerTitle
        view.backgroundColor = .systemBackground
        
        setupViews()
        loadHistory()
    }
    
    private func setupViews() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        inputContainer.backgroundColor = .secondarySystemBackground
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(inputContainer)
        
        textField.placeholder = "Написать сообщение..."
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(textField)
        
        sendButton.setTitle("Отправить", for: .normal)
        sendButton.setTitleColor(UIColor(red: 0.18, green: 0.52, blue: 0.92, alpha: 1.0), for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .semibold)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            inputContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            inputContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            inputContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            inputContainer.heightAnchor.constraint(equalToConstant: 52),
            
            textField.leadingAnchor.constraint(equalTo: inputContainer.leadingAnchor, constant: 12),
            textField.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            textField.heightAnchor.constraint(equalToConstant: 36),
            
            sendButton.trailingAnchor.constraint(equalTo: inputContainer.trailingAnchor, constant: -12),
            sendButton.centerYAnchor.constraint(equalTo: inputContainer.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 80),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainer.topAnchor)
        ])
    }
    
    private func loadHistory() {
        VKAPIService.shared.getHistory(peerId: peerId) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let resp):
                self.messages = resp.items.reversed()
                self.tableView.reloadData()
                if !self.messages.isEmpty {
                    let lastIndex = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.scrollToRow(at: lastIndex, at: .bottom, animated: false)
                }
            case .failure(let error):
                print("Ошибка истории сообщений: \(error)")
            }
        }
    }
    
    @objc private func sendTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        textField.text = ""
        
        VKAPIService.shared.sendMessage(peerId: peerId, text: text) { [weak self] result in
            switch result {
            case .success:
                self?.loadHistory()
            case .failure(let error):
                print("Ошибка отправки: \(error)")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let msg = messages[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MsgCell")
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = msg.text
        cell.selectionStyle = .none
        
        if msg.out == 1 {
            cell.textLabel?.textAlignment = .right
            cell.textLabel?.textColor = UIColor(red: 0.18, green: 0.52, blue: 0.92, alpha: 1.0)
        } else {
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .label
        }
        return cell
    }
}

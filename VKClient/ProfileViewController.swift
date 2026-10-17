import UIKit

final class ProfileViewController: UIViewController {
    private var currentUser: VKUser?
    
    private let nameLabel = UILabel()
    private let statusLabel = UILabel()
    private let logoutButton = UIButton(type: .system)
    private let avatarImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Профиль"
        view.backgroundColor = .systemBackground
        
        setupViews()
        loadProfile()
    }
    
    private func setupViews() {
        avatarImageView.backgroundColor = UIColor(red: 0.18, green: 0.52, blue: 0.92, alpha: 0.2)
        avatarImageView.layer.cornerRadius = 45
        avatarImageView.clipsToBounds = true
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(avatarImageView)
        
        nameLabel.font = .systemFont(ofSize: 22, weight: .bold)
        nameLabel.textAlignment = .center
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)
        
        statusLabel.font = .systemFont(ofSize: 15)
        statusLabel.textColor = .secondaryLabel
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 2
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        logoutButton.setTitle("Выйти из аккаунта", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        logoutButton.layer.borderWidth = 1
        logoutButton.layer.borderColor = UIColor.systemRed.cgColor
        logoutButton.layer.cornerRadius = 10
        logoutButton.addTarget(self, action: #selector(logoutTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            avatarImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 90),
            avatarImageView.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            logoutButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            logoutButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func loadProfile() {
        VKAPIService.shared.getCurrentUser { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                self.currentUser = user
                self.nameLabel.text = user.fullName
                self.statusLabel.text = user.status ?? (user.isOnline ? "В сети" : "")
            case .failure(let error):
                print("Ошибка профиля: \(error)")
            }
        }
    }
    
    @objc private func logoutTapped() {
        let alert = UIAlertController(title: "Выход", message: "Вы уверены, что хотите выйти из учетной записи?", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Выйти", style: .destructive, handler: { _ in
            VKAPIService.shared.logout()
            (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.showAuth()
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
}

import UIKit

final class ViewController: UIViewController {
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stateLabel = UILabel()
    private let detailsLabel = UILabel()
    private let activity = UIActivityIndicatorView(style: .medium)
    private let checkButton = UIButton(type: .system)
    private let loginButton = UIButton(type: .system)
    private let panel = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)
        configureUI()
        checkConnection()
    }

    private func configureUI() {
        titleLabel.text = "VK Client"
        titleLabel.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.08, green: 0.18, blue: 0.34, alpha: 1)

        subtitleLabel.text = "Нативная версия для iOS 13"
        subtitleLabel.font = UIFont.systemFont(ofSize: 15)
        subtitleLabel.textColor = .secondaryLabel

        stateLabel.text = "Проверка подключения..."
        stateLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)

        detailsLabel.text = "Проверяем VK API напрямую, без Safari и WKWebView."
        detailsLabel.font = UIFont.systemFont(ofSize: 14)
        detailsLabel.textColor = .secondaryLabel

        [titleLabel, subtitleLabel, stateLabel, detailsLabel].forEach {
            $0.numberOfLines = 0
        }

        panel.backgroundColor = .white
        panel.layer.cornerRadius = 16
        panel.layer.shadowColor = UIColor.black.cgColor
        panel.layer.shadowOpacity = 0.07
        panel.layer.shadowRadius = 12
        panel.layer.shadowOffset = CGSize(width: 0, height: 5)

        checkButton.setTitle("Повторить проверку", for: .normal)
        checkButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        checkButton.backgroundColor = UIColor(red: 0.03, green: 0.47, blue: 0.95, alpha: 1)
        checkButton.setTitleColor(.white, for: .normal)
        checkButton.layer.cornerRadius = 10
        checkButton.addTarget(self, action: #selector(checkConnection), for: .touchUpInside)

        loginButton.setTitle("Авторизация VK ID", for: .normal)
        loginButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        loginButton.setTitleColor(.systemBlue, for: .normal)
        loginButton.addTarget(self, action: #selector(explainLogin), for: .touchUpInside)

        let infoLabel = UILabel()
        infoLabel.text = "Версия 0.2 • Диагностика API\nВход в аккаунт пока не подключён. Пароль и токен вводить не требуется."
        infoLabel.font = UIFont.systemFont(ofSize: 13)
        infoLabel.textColor = .secondaryLabel
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, panel, checkButton, loginButton, infoLabel])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)

        let cardStack = UIStackView(arrangedSubviews: [stateLabel, detailsLabel, activity])
        cardStack.axis = .vertical
        cardStack.alignment = .leading
        cardStack.spacing = 12
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        panel.addSubview(cardStack)
        activity.hidesWhenStopped = true

        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: guide.topAnchor, constant: 30),
            stack.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -24),
            cardStack.topAnchor.constraint(equalTo: panel.topAnchor, constant: 20),
            cardStack.bottomAnchor.constraint(equalTo: panel.bottomAnchor, constant: -20),
            cardStack.leadingAnchor.constraint(equalTo: panel.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: panel.trailingAnchor, constant: -20),
            checkButton.heightAnchor.constraint(equalToConstant: 48),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc private func checkConnection() {
        stateLabel.text = "Проверяем VK API..."
        detailsLabel.text = "Адрес: api.vk.com. Используется URLSession."
        activity.startAnimating()
        checkButton.isEnabled = false

        VKAPIClient.shared.probe { [weak self] result in
            guard let self = self else { return }
            self.activity.stopAnimating()
            self.checkButton.isEnabled = true
            switch result {
            case let .reachable(code, message):
                if code == 15 {
                    self.stateLabel.text = "VK API доступен"
                    self.detailsLabel.text = "Получена ожидаемая ошибка VK №15: нужен токен. Подключение работает, но авторизации ещё нет."
                } else {
                    self.stateLabel.text = "VK API ответил"
                    self.detailsLabel.text = "Код VK: \(code). \(message)"
                }
            case let .unexpected(message):
                self.stateLabel.text = "Неожиданный ответ"
                self.detailsLabel.text = message
            case let .failed(message):
                self.stateLabel.text = "Ошибка соединения"
                self.detailsLabel.text = message
            }
        }
    }

    @objc private func explainLogin() {
        let alert = UIAlertController(
            title: "VK ID ещё не настроен",
            message: "Для безопасного входа необходим зарегистрированный client ID и подтверждённый способ возврата из VK ID. Текущий IPA подписан через ldid, поэтому Universal Links пока не гарантированы. Мы не просим пароль или токен вручную.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Понятно", style: .default))
        present(alert, animated: true)
    }
}

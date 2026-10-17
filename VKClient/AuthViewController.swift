import UIKit
import WebKit

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticateSuccessfully()
}

final class AuthViewController: UIViewController, WKNavigationDelegate {
    weak var delegate: AuthViewControllerDelegate?
    
    private var webView: WKWebView!
    private let tokenField = UITextField()
    private let loginButton = UIButton(type: .system)
    private let segmentedControl = UISegmentedControl(items: ["Веб-вход (OAuth)", "Ввод токена"])
    private let containerView = UIView()
    
    // VK App ID (VK Admin / Desktop OAuth ID для полного доступа)
    // 6121396 (VK Admin), 2685278 (Kate Mobile) или 6287487 (VK Desktop)
    private let vkClientId = "6121396"
    private let scope = "friends,photos,audio,video,status,wall,messages,offline"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Вход ВКонтакте"
        view.backgroundColor = .systemBackground
        setupUI()
        loadOAuthPage()
    }
    
    private func setupUI() {
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(segmentedControl)
        
        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        containerView.isHidden = true
        containerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(containerView)
        
        let tokenLabel = UILabel()
        tokenLabel.text = "Вставьте Access Token ВКонтакте:"
        tokenLabel.font = .systemFont(ofSize: 15, weight: .medium)
        tokenLabel.textColor = .label
        tokenLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tokenLabel)
        
        tokenField.placeholder = "vk1.a... или токен Kate Mobile"
        tokenField.borderStyle = .roundedRect
        tokenField.autocorrectionType = .no
        tokenField.autocapitalizationType = .none
        tokenField.font = .systemFont(ofSize: 14)
        tokenField.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(tokenField)
        
        let hintLabel = UILabel()
        hintLabel.text = "Вы можете получить токен на vkhost.github.io или через VK Admin. Этот способ обходит любые ошибки авторизации."
        hintLabel.numberOfLines = 0
        hintLabel.font = .systemFont(ofSize: 13)
        hintLabel.textColor = .secondaryLabel
        hintLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(hintLabel)
        
        loginButton.setTitle("Войти по токену", for: .normal)
        loginButton.backgroundColor = UIColor(red: 0.18, green: 0.52, blue: 0.92, alpha: 1.0)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        loginButton.layer.cornerRadius = 10
        loginButton.addTarget(self, action: #selector(handleTokenLogin), for: .touchUpInside)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            webView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 12),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            containerView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor, constant: 20),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            tokenLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            tokenLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tokenLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            tokenField.topAnchor.constraint(equalTo: tokenLabel.bottomAnchor, constant: 8),
            tokenField.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            tokenField.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            tokenField.heightAnchor.constraint(equalToConstant: 44),
            
            hintLabel.topAnchor.constraint(equalTo: tokenField.bottomAnchor, constant: 10),
            hintLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            hintLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            loginButton.topAnchor.constraint(equalTo: hintLabel.bottomAnchor, constant: 24),
            loginButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            loginButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
    
    private func loadOAuthPage() {
        let authUrlString = "https://oauth.vk.com/authorize?client_id=\(vkClientId)&display=mobile&redirect_uri=https://oauth.vk.com/blank.html&scope=\(scope)&response_type=token&v=5.131"
        if let url = URL(string: authUrlString) {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc private func segmentChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            webView.isHidden = false
            containerView.isHidden = true
        } else {
            webView.isHidden = true
            containerView.isHidden = false
        }
    }
    
    @objc private func handleTokenLogin() {
        guard let token = tokenField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !token.isEmpty else {
            showAlert(message: "Пожалуйста, введите токен")
            return
        }
        
        VKAPIService.shared.token = token
        verifyAndProceed()
    }
    
    // Перехват редиректа с токеном в WKWebView
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.absoluteString.contains("oauth.vk.com/blank.html") {
            let fragment = url.fragment ?? ""
            let params = fragment.components(separatedBy: "&")
            var token: String?
            var userId: Int?
            
            for param in params {
                let pair = param.components(separatedBy: "=")
                if pair.count == 2 {
                    if pair[0] == "access_token" { token = pair[1] }
                    if pair[0] == "user_id" { userId = Int(pair[1]) }
                }
            }
            
            if let token = token {
                VKAPIService.shared.token = token
                VKAPIService.shared.currentUserId = userId
                decisionHandler(.cancel)
                verifyAndProceed()
                return
            }
        }
        decisionHandler(.allow)
    }
    
    private func verifyAndProceed() {
        VKAPIService.shared.getCurrentUser { [weak self] result in
            switch result {
            case .success:
                self?.delegate?.didAuthenticateSuccessfully()
                self?.dismiss(animated: true)
            case .failure(let error):
                self?.showAlert(message: "Ошибка проверки токена: \(error.localizedDescription)")
            }
        }
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "ВКонтакте", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

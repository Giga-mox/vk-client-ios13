import UIKit
import WebKit

final class ViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let startURL = URL(string: "https://m.vk.com/")!
    private var webView: WKWebView!
    private let titleLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .gray)
    private let progress = UIProgressView(progressViewStyle: .bar)
    private let backButton = UIButton(type: .system)
    private let forwardButton = UIButton(type: .system)
    private var observations: [NSKeyValueObservation] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let config = WKWebViewConfiguration()
        config.websiteDataStore = .default()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.translatesAutoresizingMaskIntoConstraints = false

        let header = UIView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.backgroundColor = .systemBackground

        titleLabel.text = "VK"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        spinner.translatesAutoresizingMaskIntoConstraints = false
        progress.translatesAutoresizingMaskIntoConstraints = false
        progress.tintColor = UIColor(red: 0.03, green: 0.47, blue: 0.95, alpha: 1)
        progress.trackTintColor = .clear

        let toolbar = UIStackView()
        toolbar.axis = .horizontal
        toolbar.distribution = .fillEqually
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        toolbar.backgroundColor = .systemBackground

        configure(backButton, symbol: "chevron.left", fallback: "‹", action: #selector(goBack))
        configure(forwardButton, symbol: "chevron.right", fallback: "›", action: #selector(goForward))
        let home = UIButton(type: .system)
        configure(home, symbol: "house", fallback: "⌂", action: #selector(goHome))
        let reload = UIButton(type: .system)
        configure(reload, symbol: "arrow.clockwise", fallback: "↻", action: #selector(reloadPage))
        let share = UIButton(type: .system)
        configure(share, symbol: "square.and.arrow.up", fallback: "↑", action: #selector(sharePage))

        [backButton, forwardButton, home, reload, share].forEach { toolbar.addArrangedSubview($0) }
        view.addSubview(header)
        header.addSubview(titleLabel)
        header.addSubview(spinner)
        header.addSubview(progress)
        view.addSubview(webView)
        view.addSubview(toolbar)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: safe.topAnchor),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            header.heightAnchor.constraint(equalToConstant: 44),
            titleLabel.centerXAnchor.constraint(equalTo: header.centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            titleLabel.widthAnchor.constraint(lessThanOrEqualTo: header.widthAnchor, multiplier: 0.72),
            spinner.centerYAnchor.constraint(equalTo: header.centerYAnchor),
            spinner.trailingAnchor.constraint(equalTo: header.trailingAnchor, constant: -20),
            progress.leadingAnchor.constraint(equalTo: header.leadingAnchor),
            progress.trailingAnchor.constraint(equalTo: header.trailingAnchor),
            progress.bottomAnchor.constraint(equalTo: header.bottomAnchor),
            webView.topAnchor.constraint(equalTo: header.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: toolbar.topAnchor),
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: safe.bottomAnchor),
            toolbar.heightAnchor.constraint(equalToConstant: 48)
        ])

        observations.append(webView.observe(\.estimatedProgress, options: [.initial, .new]) { [weak self] view, _ in
            DispatchQueue.main.async {
                self?.progress.progress = Float(view.estimatedProgress)
                self?.progress.isHidden = !view.isLoading || view.estimatedProgress >= 1
            }
        })
        observations.append(webView.observe(\.canGoBack, options: [.initial, .new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.updateButtons() }
        })
        observations.append(webView.observe(\.canGoForward, options: [.initial, .new]) { [weak self] _, _ in
            DispatchQueue.main.async { self?.updateButtons() }
        })
        webView.load(URLRequest(url: startURL))
    }

    private func configure(_ button: UIButton, symbol: String, fallback: String, action: Selector) {
        if let image = UIImage(systemName: symbol) {
            button.setImage(image, for: .normal)
        } else {
            button.setTitle(fallback, for: .normal)
        }
        button.tintColor = UIColor(red: 0.03, green: 0.47, blue: 0.95, alpha: 1)
        button.addTarget(self, action: action, for: .touchUpInside)
        button.accessibilityLabel = symbol
    }

    private func updateButtons() {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        backButton.alpha = webView.canGoBack ? 1 : 0.3
        forwardButton.alpha = webView.canGoForward ? 1 : 0.3
    }

    @objc private func goBack() { if webView.canGoBack { webView.goBack() } }
    @objc private func goForward() { if webView.canGoForward { webView.goForward() } }
    @objc private func goHome() { webView.load(URLRequest(url: startURL)) }
    @objc private func reloadPage() { webView.reload() }
    @objc private func sharePage() {
        let items: [Any] = [webView.url ?? startURL]
        let sheet = UIActivityViewController(activityItems: items, applicationActivities: nil)
        sheet.popoverPresentationController?.sourceView = view
        present(sheet, animated: true)
    }

    private func updateLoading(_ loading: Bool) {
        if loading { spinner.startAnimating() } else { spinner.stopAnimating() }
        progress.isHidden = !loading
        updateButtons()
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        updateLoading(true)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        updateLoading(false)
        titleLabel.text = "VK"
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        updateLoading(false)
        showError(error)
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        updateLoading(false)
        showError(error)
    }
    private func showError(_ error: Error) {
        if (error as NSError).code == NSURLErrorCancelled { return }
        let alert = UIAlertController(title: "Не удалось открыть страницу", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Повторить", style: .default) { [weak self] _ in self?.webView.reload() })
        alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel))
        present(alert, animated: true)
    }

    // Target=_blank, including VK ID login links, stays inside the same session.
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil, let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { decisionHandler(.cancel); return }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            if UIApplication.shared.canOpenURL(url) { UIApplication.shared.open(url) }
            decisionHandler(.cancel)
            return
        }
        // Open unrelated sites in Safari; VK pages, VK ID and account auth remain in the client.
        if navigationAction.targetFrame?.isMainFrame == true,
           let host = url.host?.lowercased(),
           !["vk.com", "vk.ru", "vkid.ru", "vk.me", "login.vk.com"].contains(where: { host == $0 || host.hasSuffix("." + $0) }) {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
            return
        }
        decisionHandler(.allow)
    }
}

import Foundation

struct VKAPIError: Decodable {
    let error_code: Int
    let error_msg: String
}
struct VKAPIEnvelope: Decodable {
    let error: VKAPIError?
}

struct DiagnosticResult {
    let endpoint: String
    let details: String
    let success: Bool
}

final class VKAPIClient {
    static let shared = VKAPIClient()
    private init() {}

    /// Check several HTTPS hosts to distinguish VK-side errors from an app-wide
    /// iOS networking or signing restriction. No credentials are transmitted.
    func diagnose(completion: @escaping ([DiagnosticResult]) -> Void) {
        let urls = [
            "https://api.vk.com/method/users.get?v=5.199",
            "https://www.apple.com/",
            "https://www.google.com/"
        ]
        let group = DispatchGroup()
        let lock = NSLock()
        var results = [DiagnosticResult?](repeating: nil, count: urls.count)

        for (index, urlString) in urls.enumerated() {
            group.enter()
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = 12
            configuration.timeoutIntervalForResource = 15
            configuration.waitsForConnectivity = false
            configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
            let session = URLSession(configuration: configuration)
            var request = URLRequest(url: URL(string: urlString)!)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            session.dataTask(with: request) { data, response, error in
                let result: DiagnosticResult
                if let error = error as NSError? {
                    let underlying = error.userInfo[NSUnderlyingErrorKey] as? NSError
                    var message = "\(error.domain) \(error.code): \(error.localizedDescription)"
                    if let underlying = underlying {
                        message += "\nUnderlying: \(underlying.domain) \(underlying.code)"
                    }
                    if let reason = error.userInfo["NSURLErrorNetworkUnavailableReasonKey"] {
                        message += "\nNetwork reason: \(reason)"
                    }
                    for source in [error, underlying].compactMap({ $0 }) {
                        for key in ["_NSURLErrorNWPathKey", "NSURLErrorNetworkUnavailableReasonKey",
                                    "_kCFStreamErrorCodeKey", "_kCFStreamErrorDomainKey"] {
                            if let value = source.userInfo[key] {
                                message += "\n\(key): \(value)"
                            }
                        }
                    }
                    result = DiagnosticResult(endpoint: URL(string: urlString)!.host ?? urlString,
                                              details: message, success: false)
                } else if let http = response as? HTTPURLResponse {
                    var message = "HTTP \(http.statusCode)"
                    if index == 0, let data = data,
                       let envelope = try? JSONDecoder().decode(VKAPIEnvelope.self, from: data),
                       let vkError = envelope.error {
                        message += ", VK error \(vkError.error_code): \(vkError.error_msg)"
                    }
                    result = DiagnosticResult(endpoint: URL(string: urlString)!.host ?? urlString,
                                              details: message, success: (200...399).contains(http.statusCode))
                } else {
                    result = DiagnosticResult(endpoint: URL(string: urlString)!.host ?? urlString,
                                              details: "Ответ не содержит HTTP-статус", success: false)
                }
                lock.lock()
                results[index] = result
                lock.unlock()
                session.finishTasksAndInvalidate()
                group.leave()
            }.resume()
        }
        group.notify(queue: .main) {
            completion(results.compactMap { $0 })
        }
    }
}

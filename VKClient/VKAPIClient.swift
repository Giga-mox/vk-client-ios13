import Foundation

struct VKAPIError: Decodable {
    let error_code: Int
    let error_msg: String
}
struct VKAPIEnvelope: Decodable {
    let error: VKAPIError?
}

enum VKAPIProbeResult {
    case reachable(code: Int, message: String)
    case unexpected(String)
    case failed(String)
}

final class VKAPIClient {
    static let shared = VKAPIClient()
    private let session: URLSession

    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 20
        configuration.waitsForConnectivity = false
        session = URLSession(configuration: configuration)
    }

    /// A request without a token is intentional. VK API error 15 means
    /// the endpoint is reachable, NOT that the user is authenticated.
    func probe(completion: @escaping (VKAPIProbeResult) -> Void) {
        let url = URL(string: "https://api.vk.com/method/users.get?v=5.199")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .reloadIgnoringLocalCacheData
        session.dataTask(with: request) { data, response, error in
            let result: VKAPIProbeResult
            if let error = error {
                result = .failed(error.localizedDescription)
            } else if let response = response as? HTTPURLResponse,
                      !(200...299).contains(response.statusCode) {
                result = .failed("HTTP \(response.statusCode)")
            } else if let data = data,
                      let decoded = try? JSONDecoder().decode(VKAPIEnvelope.self, from: data),
                      let vkError = decoded.error {
                result = .reachable(code: vkError.error_code, message: vkError.error_msg)
            } else {
                result = .unexpected("Сервер ответил, но формат ответа отличается от ожидаемого.")
            }
            DispatchQueue.main.async { completion(result) }
        }.resume()
    }
}

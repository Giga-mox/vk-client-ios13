import Foundation

final class VKAPIService {
    static let shared = VKAPIService()
    private let apiVersion = "5.131"
    private let baseUrl = "https://api.vk.com/method/"
    
    private init() {}
    
    var token: String? {
        get { UserDefaults.standard.string(forKey: "vk_access_token") }
        set { UserDefaults.standard.set(newValue, forKey: "vk_access_token") }
    }
    
    var currentUserId: Int? {
        get { UserDefaults.standard.integer(forKey: "vk_user_id") }
        set { UserDefaults.standard.set(newValue, forKey: "vk_user_id") }
    }
    
    var isAuthenticated: Bool {
        guard let token = token, !token.isEmpty else { return false }
        return true
    }
    
    func logout() {
        token = nil
        currentUserId = nil
    }
    
    // Универсальный вызов методов VK API
    func request<T: Decodable>(method: String, params: [String: String], completion: @escaping (Result<T, Error>) -> Void) {
        guard let token = token else {
            completion(.failure(NSError(domain: "VKAuth", code: 401, userInfo: [NSLocalizedDescriptionKey: "Требуется авторизация"])))
            return
        }
        
        var queryItems = [
            URLQueryItem(name: "access_token", value: token),
            URLQueryItem(name: "v", value: apiVersion)
        ]
        
        for (key, value) in params {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        
        guard var components = URLComponents(string: baseUrl + method) else {
            completion(.failure(NSError(domain: "VKAPI", code: 400, userInfo: [NSLocalizedDescriptionKey: "Неверный URL"])))
            return
        }
        components.queryItems = queryItems
        
        guard let url = components.url else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "VKAPI", code: 500, userInfo: [NSLocalizedDescriptionKey: "Пустой ответ сервера"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(VKResponseWrapper<T>.self, from: data)
                if let responseData = response.response {
                    DispatchQueue.main.async { completion(.success(responseData)) }
                } else if let vkError = response.error {
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "VKAPI", code: vkError.errorCode, userInfo: [NSLocalizedDescriptionKey: vkError.errorMsg])))
                    }
                }
            } catch {
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    // Получение текущего пользователя
    func getCurrentUser(completion: @escaping (Result<VKUser, Error>) -> Void) {
        request(method: "users.get", params: ["fields": "photo_200,status,counters,online,city,country"]) { (result: Result<[VKUser], Error>) in
            switch result {
            case .success(let users):
                if let user = users.first {
                    self.currentUserId = user.id
                    completion(.success(user))
                } else {
                    completion(.failure(NSError(domain: "VK", code: 404, userInfo: [NSLocalizedDescriptionKey: "Пользователь не найден"])))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    // Получение ленты новостей
    func getNewsfeed(startFrom: String? = nil, completion: @escaping (Result<VKNewsfeedResponse, Error>) -> Void) {
        var params = [
            "filters": "post",
            "count": "25"
        ]
        if let startFrom = startFrom {
            params["start_from"] = startFrom
        }
        request(method: "newsfeed.get", params: params, completion: completion)
    }
    
    // Диалоги / сообщения
    func getConversations(count: Int = 30, completion: @escaping (Result<VKConversationsResponse, Error>) -> Void) {
        let params = [
            "count": String(count),
            "extended": "1",
            "fields": "first_name,last_name,photo_100,online"
        ]
        request(method: "messages.getConversations", params: params, completion: completion)
    }
    
    // История переписки в чате
    func getHistory(peerId: Int, count: Int = 40, completion: @escaping (Result<VKHistoryResponse, Error>) -> Void) {
        let params = [
            "peer_id": String(peerId),
            "count": String(count),
            "extended": "1"
        ]
        request(method: "messages.getHistory", params: params, completion: completion)
    }
    
    // Отправка сообщения
    func sendMessage(peerId: Int, text: String, completion: @escaping (Result<Int, Error>) -> Void) {
        let randomId = Int.random(in: 1...1_000_000_000)
        let params = [
            "peer_id": String(peerId),
            "message": text,
            "random_id": String(randomId)
        ]
        request(method: "messages.send", params: params, completion: completion)
    }
    
    // Список друзей
    func getFriends(completion: @escaping (Result<VKFriendsResponse, Error>) -> Void) {
        let params = [
            "order": "hints",
            "fields": "first_name,last_name,photo_100,online,status",
            "count": "100"
        ]
        request(method: "friends.get", params: params, completion: completion)
    }
}

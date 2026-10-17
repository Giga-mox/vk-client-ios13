import Foundation

struct VKResponseWrapper<T: Decodable>: Decodable {
    let response: T?
    let error: VKAPIError?
}

struct VKAPIError: Decodable {
    let errorCode: Int
    let errorMsg: String
}

struct VKUser: Decodable {
    let id: Int
    let firstName: String
    let lastName: String
    let photo100: String?
    let photo200: String?
    let status: String?
    let online: Int?
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    var isOnline: Bool {
        return (online ?? 0) == 1
    }
}

struct VKGroup: Decodable {
    let id: Int
    let name: String
    let photo100: String?
}

struct VKNewsfeedResponse: Decodable {
    let items: [VKPost]
    let profiles: [VKUser]?
    let groups: [VKGroup]?
    let nextFrom: String?
}

struct VKPost: Decodable {
    let postId: Int?
    let id: Int?
    let sourceId: Int
    let date: Double
    let text: String
    let likes: VKLikes?
    let reposts: VKReposts?
    let comments: VKComments?
    let attachments: [VKAttachment]?
}

struct VKLikes: Decodable {
    let count: Int
    let userLikes: Int?
}

struct VKReposts: Decodable {
    let count: Int
}

struct VKComments: Decodable {
    let count: Int
}

struct VKAttachment: Decodable {
    let type: String
    let photo: VKPhoto?
}

struct VKPhoto: Decodable {
    let id: Int
    let sizes: [VKPhotoSize]
    
    var optimalUrl: String? {
        // Выбираем размер близкий к 604 или самый крупный
        if let size = sizes.first(where: { $0.type == "x" || $0.type == "y" || $0.type == "z" }) {
            return size.url
        }
        return sizes.last?.url
    }
}

struct VKPhotoSize: Decodable {
    let type: String
    let url: String
    let width: Int
    let height: Int
}

struct VKConversationsResponse: Decodable {
    let count: Int
    let items: [VKConversationItem]
    let profiles: [VKUser]?
    let groups: [VKGroup]?
}

struct VKConversationItem: Decodable {
    let conversation: VKConversation
    let lastMessage: VKMessage
}

struct VKConversation: Decodable {
    let peer: VKPeer
    let unreadCount: Int?
}

struct VKPeer: Decodable {
    let id: Int
    let type: String
    let localId: Int
}

struct VKHistoryResponse: Decodable {
    let count: Int
    let items: [VKMessage]
}

struct VKMessage: Decodable {
    let id: Int
    let date: Double
    let peerId: Int
    let fromId: Int
    let text: String
    let out: Int
}

struct VKFriendsResponse: Decodable {
    let count: Int
    let items: [VKUser]
}

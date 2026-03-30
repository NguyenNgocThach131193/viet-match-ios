#if UIPREVIEW

import Foundation

// MARK: - Mock Data Factory

enum MockData {

    // MARK: - Current User

    static let currentUserId = "mock-user-001"

    static let currentUser = User(
        id: currentUserId,
        email: "demo@vietmatch.app",
        displayName: "Minh Anh",
        profileCompleted: true,
        createdAt: Date().addingTimeInterval(-86400 * 30),
        lastActiveAt: Date()
    )

    // MARK: - Profiles

    static let currentProfile = Profile(
        id: currentUserId,
        name: "Minh Anh",
        age: 26,
        bio: "Thich di cafe, doc sach va chay bo moi sang",
        gender: .female,
        interestedIn: .male,
        photos: [
            "https://picsum.photos/seed/user1a/400/600",
            "https://picsum.photos/seed/user1b/400/600",
            "https://picsum.photos/seed/user1c/400/600"
        ],
        location: Location(latitude: 10.7769, longitude: 106.7009, city: "Ho Chi Minh"),
        interests: ["Cafe", "Sach", "Chay bo", "Du lich"],
        jobTitle: "UX Designer",
        company: "TechVN",
        school: "DH Bach Khoa HCM"
    )

    static let discoverProfiles: [Profile] = [
        Profile(
            id: "mock-user-002",
            name: "Thanh Tung",
            age: 28,
            bio: "Software engineer by day, guitarist by night. Dang tim nguoi cung di kham pha quan an moi",
            gender: .male,
            interestedIn: .female,
            photos: [
                "https://picsum.photos/seed/user2a/400/600",
                "https://picsum.photos/seed/user2b/400/600"
            ],
            location: Location(latitude: 10.7890, longitude: 106.7100, city: "Ho Chi Minh"),
            interests: ["Guitar", "Coding", "Am thuc", "Phim"],
            jobTitle: "Senior Developer",
            company: "FPT Software",
            school: "DH Cong Nghe Thong Tin"
        ),
        Profile(
            id: "mock-user-003",
            name: "Huong Giang",
            age: 24,
            bio: "Co gai Ha Noi vao Sai Gon lap nghiep. Thich nau an va chup hinh",
            gender: .female,
            interestedIn: .male,
            photos: [
                "https://picsum.photos/seed/user3a/400/600",
                "https://picsum.photos/seed/user3b/400/600",
                "https://picsum.photos/seed/user3c/400/600",
                "https://picsum.photos/seed/user3d/400/600"
            ],
            location: Location(latitude: 10.7800, longitude: 106.6950, city: "Ho Chi Minh"),
            interests: ["Nau an", "Chup hinh", "Yoga", "Ca phe"],
            jobTitle: "Marketing Executive",
            company: "Shopee",
            school: "DH Ngoai Thuong HN"
        ),
        Profile(
            id: "mock-user-004",
            name: "Duc Anh",
            age: 30,
            bio: "Bac si tai BV Cho Ray. Work-life balance la triet ly song",
            gender: .male,
            interestedIn: .female,
            photos: [
                "https://picsum.photos/seed/user4a/400/600"
            ],
            location: Location(latitude: 10.7550, longitude: 106.6600, city: "Ho Chi Minh"),
            interests: ["Y hoc", "Tennis", "Doc sach", "Nau an"],
            jobTitle: "Bac si Noi khoa",
            company: "BV Cho Ray",
            school: "DH Y Duoc HCM"
        ),
        Profile(
            id: "mock-user-005",
            name: "Thuy Linh",
            age: 25,
            bio: "Giao vien tieng Anh, thich di phuot va nuoi meo",
            gender: .female,
            interestedIn: .male,
            photos: [
                "https://picsum.photos/seed/user5a/400/600",
                "https://picsum.photos/seed/user5b/400/600",
                "https://picsum.photos/seed/user5c/400/600",
                "https://picsum.photos/seed/user5d/400/600",
                "https://picsum.photos/seed/user5e/400/600",
                "https://picsum.photos/seed/user5f/400/600"
            ],
            location: Location(latitude: 10.8000, longitude: 106.7200, city: "Ho Chi Minh"),
            interests: ["Du lich", "Meo", "Tieng Anh", "Photography"],
            jobTitle: "English Teacher",
            company: "IELTS Academy",
            school: "DH Su Pham HCM"
        )
    ]

    // MARK: - Matches

    static let matches: [Match] = [
        Match(
            id: "match-001",
            userId: currentUserId,
            matchedUserId: "mock-user-003",
            matchedProfile: discoverProfiles[1],
            createdAt: Date().addingTimeInterval(-86400 * 2),
            lastMessageAt: Date().addingTimeInterval(-3600),
            isNew: false
        ),
        Match(
            id: "match-002",
            userId: currentUserId,
            matchedUserId: "mock-user-005",
            matchedProfile: discoverProfiles[3],
            createdAt: Date().addingTimeInterval(-86400),
            lastMessageAt: nil,
            isNew: true
        )
    ]

    // MARK: - Messages

    static let messages: [Message] = [
        Message(
            id: "msg-001",
            matchId: "match-001",
            senderId: "mock-user-003",
            content: "Hey, minh thay ban cung thich chup hinh!",
            createdAt: Date().addingTimeInterval(-7200),
            isRead: true
        ),
        Message(
            id: "msg-002",
            matchId: "match-001",
            senderId: currentUserId,
            content: "Dung roi! Ban hay chup the loai gi?",
            createdAt: Date().addingTimeInterval(-6800),
            isRead: true
        ),
        Message(
            id: "msg-003",
            matchId: "match-001",
            senderId: "mock-user-003",
            content: "Minh thich chup street photography, cuoi tuan hay di quan 1 chup lam",
            createdAt: Date().addingTimeInterval(-6500),
            isRead: true
        ),
        Message(
            id: "msg-004",
            matchId: "match-001",
            senderId: currentUserId,
            content: "Nghe hay qua! Minh cung dang tap chup, co khi nao minh di chup chung khong?",
            createdAt: Date().addingTimeInterval(-3600),
            isRead: false
        )
    ]

    // MARK: - Conversations

    static let conversations: [Conversation] = [
        Conversation(
            id: "match-001",
            match: matches[0],
            lastMessage: messages.last,
            unreadCount: 0
        ),
        Conversation(
            id: "match-002",
            match: matches[1],
            lastMessage: nil,
            unreadCount: 0
        )
    ]
}

#endif

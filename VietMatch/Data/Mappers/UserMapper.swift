import Foundation

enum UserMapper {
    static func toDTO(from user: User) -> UserDTO {
        UserDTO.from(domain: user)
    }

    static func toDomain(from dto: UserDTO) -> User {
        dto.toDomain()
    }
}

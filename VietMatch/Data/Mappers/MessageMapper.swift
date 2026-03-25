import Foundation

enum MessageMapper {
    static func toDTO(from message: Message) -> MessageDTO {
        MessageDTO.from(domain: message)
    }

    static func toDomain(from dto: MessageDTO) -> Message {
        dto.toDomain()
    }
}

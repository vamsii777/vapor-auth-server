import Vapor
import Fluent
import VaporOAuth

final class CryptoKey: Model, Content {
    
    static let schema = "crypto_keys"
    static let database: DatabaseID = .keyManagement
    
    @ID(key: .id) var id: UUID?
    @Field(key: "key_type") var keyType: KeyType // "public", "private", etc.
    @Field(key: "key_value") var keyValue: String // The key itself
    @Field(key: "description") var description: String? // Purpose or description
    @Field(key: "valid_from") var validFrom: Date // Start date of key validity
    @Field(key: "valid_until") var validUntil: Date? // Optional end date of key validity
    @Field(key: "is_active") var isActive: Bool // Whether the key is currently active
    @Timestamp(key: "created_at", on: .create) var createdAt: Date? // Creation timestamp
    @Timestamp(key: "updated_at", on: .update) var updatedAt: Date? // Last update timestamp
    
    init() {}
    
    init(id: UUID? = nil, keyType: KeyType, keyValue: String, description: String? = nil,
         validFrom: Date, validUntil: Date? = nil, isActive: Bool) {
        self.id = id
        self.keyType = keyType
        self.keyValue = keyValue
        self.description = description
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.isActive = isActive
    }
}

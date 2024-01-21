import Fluent

struct CreateCryptoKey: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(CryptoKey.schema)
            .id()
            .field("key_type", .string, .required)
            .field("key_value", .string, .required)
            .field("description", .string)
            .field("valid_from", .datetime, .required)
            .field("valid_until", .datetime)
            .field("is_active", .bool, .required)
            .field("created_at", .datetime)
            .field("updated_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(CryptoKey.schema).delete()
    }
}
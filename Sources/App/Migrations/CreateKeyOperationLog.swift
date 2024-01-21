import Fluent

struct CreateKeyOperationLog: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema(KeyOperationLog.schema)
            .id()
            .field("key_id", .uuid, .required, .references(CryptoKey.schema, "id"))
            .field("operation", .string, .required)
            .field("timestamp", .datetime, .required)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema(KeyOperationLog.schema).delete()
    }
}

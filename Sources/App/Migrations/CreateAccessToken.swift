import Fluent

struct CreateAccessToken: AsyncMigration {
   
   let schemaName: String  = AccessToken.schema
   
   func prepare(on database: Database) async throws {

      try await database.schema(schemaName)
         .id()
         .field("jti", .string, .required)
         .field("token", .string, .required)
         .field("client_id", .string, .required)
         .field("user_id", .string, .required)
         .field("scopes", .string, .required)
         .field("expiry_time", .datetime, .required)
         .create()
   }
   
   func revert(on database: Database) async throws {
      try await database.schema(schemaName)
         .delete()
   }
}

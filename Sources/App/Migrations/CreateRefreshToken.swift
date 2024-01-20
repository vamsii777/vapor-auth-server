import Fluent

struct CreateRefreshToken: AsyncMigration {
   
   let schemaName: String  = RefreshToken.schema
   
   func prepare(on database: Database) async throws {
      
      try await database.schema(schemaName)
         .id()
         .field("jti", .string, .required)
         .field("client_id", .string, .required)
         .field("user_id", .string, .required)
         .field("scopes", .string, .required)
         .field("exp", .datetime)
         .create()
   }
   
   func revert(on database: Database) async throws {
      try await database.schema(schemaName)
         .delete()
   }
}

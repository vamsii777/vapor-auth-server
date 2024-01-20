import Fluent

struct CreateIDToken: AsyncMigration {

   let schemaName: String  = IDToken.schema

   func prepare(on database: Database) async throws {

      try await database.schema(schemaName)
         .id()
         .field("jti", .string)
         .field("iss", .string)
         .field("sub", .string)
         .field("aud", .string)
         .field("exp", .datetime)
         .field("iat", .datetime)
         .field("nonce", .string)
         .field("auth_time", .datetime)
         .create()
   }

   func revert(on database: Database) async throws {
      try await database.schema(schemaName)
         .delete()
   }
}

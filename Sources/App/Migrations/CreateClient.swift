import Fluent
import Vapor

struct CreateClient: AsyncMigration {

   let schemaName: String  = Client.schema

   func prepare(on database: Database) async throws {

      // Enum must be created as database.enum
      // and is logged via the table _fluent_enums in the database
      let grantType = try await database.enum("oauth_flow_type")
         .case("authorization_code")
         .case("implicit")
         .case("password")
         .case("refresh_token")
         .case("token_introspection")
         .case("device_code")
         .create()

      try await database.schema(schemaName)
         .id()
         .field("client_id", .string, .required)
         .field("redirect_uris", .string)
         .field("client_secret", .string)
         .field("scopes", .string)
         .field("confidential_client", .bool)
         .field("first_party", .bool)
         .field("grant_type", grantType, .required) // database enum
         .unique(on: "client_id")
         .create()
   }


   func revert(on database: Database) async throws {

      try await database.schema(schemaName)
         .delete()
   }

}


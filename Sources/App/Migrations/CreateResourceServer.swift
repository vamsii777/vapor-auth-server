import Fluent
import Vapor

struct CreateResourceServer: AsyncMigration {

   let schemaName: String  = ResourceServer.schema

   func prepare(on database: Database) async throws {

      try await database.schema(schemaName)
         .id()
         .field("username", .string, .required)
         .field("password", .string, .required)
         .unique(on: "username")
         .create()
   }

   func revert(on database: Database) async throws {

      try await database.schema(schemaName)
         .delete()
   }

}


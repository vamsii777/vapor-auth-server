import Fluent
import Vapor
import VaporOAuth

struct SeedClient: AsyncMigration {

   func prepare(on database: Database) async throws {

       let client = try Client(
         clientId: "1",
         redirectUris: ["http://localhost:8089/callback"],
         clientSecret: "password123",
         scopes: ["admin","openid"],
         confidentialClient: true,
         firstParty: true,
         grantType: .authorization
      )

      return try await client.save(on: database)
   }

   func revert(on database: Database) async throws {

      try await Client.query(on: database)
         .filter(\.$clientId == "1")
         .delete()
   }

}




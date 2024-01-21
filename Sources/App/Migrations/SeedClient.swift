import Fluent
import Vapor
import VaporOAuth

struct SeedClient: AsyncMigration {

   func prepare(on database: Database) async throws {

       let client = try Client(
         clientId: "Np2bX4LcD1K9jRiV7f8U",
         redirectUris: ["http://localhost:8089/oauth/callback"],
         clientSecret: "G5sR8qP3M0bY2vS6wT1xZ4fD7uL9mP0bY2vS6wT1x",
         scopes: ["openid"],
         confidentialClient: true,
         firstParty: true,
         grantType: .authorization
      )

      return try await client.save(on: database)
   }

   func revert(on database: Database) async throws {

      try await Client.query(on: database)
         .filter(\.$clientId == "Np2bX4LcD1K9jRiV7f8U")
         .delete()
   }

}




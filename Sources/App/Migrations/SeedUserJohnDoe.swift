import Fluent
import Vapor

struct SeedUserJohnDoe: AsyncMigration {

   func prepare(on database: Database) async throws {

      let uuid = UUID(uuidString: "5c3afb78-3b44-11ec-8aa0-9c18a4eebeeb")
      let password = try Bcrypt.hash("password")

      let author = UserModel(
         id: uuid,
         username: "john_doe@something.com",
         password: password,
         emailAddress: nil,
         emailAddressVerified: nil,
         givenName: "John",
         familyName: "Doe",
         middleName: nil,
         nickname: nil,
         profile: nil,
         picture: nil,
         website: nil,
         gender: nil,
         birthdate: nil,
         zoneinfo: nil,
         locale: nil,
         phoneNumber: nil,
         phoneNumberVerified: nil,
         roles: ["admin","openid"],
         newsletter: false,
         blocked: false,
         lastLogin: nil,
         validatedAt: nil,
         cookiePreferences: .NOT_SET,
         federated: false,
         oauthProvider: .SELF
      )

      return try await author.save(on: database)
   }

   func revert(on database: Database) async throws {

      try await UserModel
         .query(on: database)
         .filter(\.$username == "john_doe@something.com")
         .delete()
   }

}




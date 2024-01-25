import Fluent
import Vapor

struct SeedUser: AsyncMigration {
   
   func prepare(on database: Database) async throws {
      
      let uuid = UUID(uuidString: "8c3afb78-3b44-11ec-8aa0-9c18a4eebeeb")
      let password = try Bcrypt.hash("passmodium@d")

      let author = UserModel(
         id: uuid,
         username: "vamsi@dewonderstruck.com",
         password: password,
         emailAddress: "vamsi@dewonderstruck.com",
         emailAddressVerified: false,
         givenName: "Vamsi",
         familyName: "Madduluri",
         middleName: nil,
         nickname: "vamsi",
         profile: nil,
         picture: nil,
         website: "https://vamsimadduluri.com",
         gender: "male",
         birthdate: nil,
         zoneinfo: nil,
         locale: nil,
         phoneNumber: nil,
         phoneNumberVerified: nil,
         roles: ["openid"],
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
         .filter(\.$username == "vamsi@dewonderstruck.com")
         .delete()
   }
   
}




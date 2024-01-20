import Fluent
import Vapor

struct CreateUser: AsyncMigration {

   let schemaName: String  = UserModel.schema

   func prepare(on database: Database) async throws {

      let cookie_preferences = try await database.enum("cookie_preferences")
         .case("NOT_SET")
         .case("ACCEPTED")
         .case("DECLINED")
         .create()

      let oauth_provider = try await database.enum("oauth_provider")
         .case("GOOGLE")
         .case("SELF")
         .create()

      try await database.schema(schemaName)
         .id()
         .field("username", .string, .required)
         .field("password", .string, .required)
         .field("given_name", .string)
         .field("family_name", .string)
         .field("middle_name", .string)
         .field("nickname", .string)
         .field("profile", .string)
         .field("picture", .string)
         .field("website", .string)
         .field("email", .string)
         .field("email_verified", .bool)
         .field("gender", .string)
         .field("birthdate", .string)
         .field("zoneinfo", .string)
         .field("locale", .string)
         .field("phone_number", .string)
         .field("phone_number_verified", .bool)
         .field("created_at", .datetime, .required)
         .field("updated_at", .datetime, .required)
         .field("cookie_preferences", cookie_preferences) // database enum
         .field("oauth_provider", oauth_provider) // database enum
         .field("federated", .bool) 
         .field("newsletter", .bool, .required)
         .field("blocked", .bool, .required)
         .field("last_login", .datetime)
         .field("number_of_logins", .int)
         .field("validated_at", .datetime)
         .field("roles", .string, .required)
         .unique(on: "username")
         .create()
   }


   func revert(on database: Database) async throws {

      try await database.schema(schemaName)
         .delete()
   }

}


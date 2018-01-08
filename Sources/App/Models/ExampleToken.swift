import Vapor
import FluentProvider

final class ExampleToken: Model {
    
    let storage = Storage()
    
    let token: String
    let userId: Identifier

    var user: Parent<ExampleToken, ExampleUser> {
        return parent(id: userId)
    }
    
    struct Keys {
        static let token = "token"
        static let userId = "userId"
    }
    
    init(row: Row) throws {
        token = try row.get(ExampleToken.Keys.token)
        userId = try row.get(ExampleToken.Keys.userId)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(ExampleToken.Keys.token, token)
        try row.set(ExampleToken.Keys.userId, userId)
        return row
    }
    
}

extension ExampleToken: Preparation {

    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(ExampleToken.Keys.token)
            builder.string(ExampleToken.Keys.userId)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}


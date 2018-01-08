import Vapor
import FluentProvider
import Routing

final class UserTemp: Model {
    let storage = Storage()
    
    var username: String
    var age: Int
    
    /// The column names for `id` and `content` in the database
    struct Keys {
        static let userid = "user_id"
        static let username = "user_name"
        static let age = "age"
    }
    
    init(username: String, age: Int) {
        self.username = username
        self.age = age
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        username = try row.get(UserTemp.Keys.username)
        age = try row.get(UserTemp.Keys.age)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(UserTemp.Keys.username, username)
        try row.set(UserTemp.Keys.age, age)
        return row
    }
}

extension UserTemp: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(UserTemp.Keys.username)
            builder.int(UserTemp.Keys.age)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension UserTemp: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            username: try json.get(UserTemp.Keys.username),
            age: try json.get(UserTemp.Keys.age)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(UserTemp.Keys.userid, id)
        try json.set(UserTemp.Keys.username, username)
        try json.set(UserTemp.Keys.age, age)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension UserTemp: ResponseRepresentable { }

extension UserTemp: Updateable {
    static var updateableKeys: [UpdateableKey<UserTemp>] {
        return [
            UpdateableKey(UserTemp.Keys.username, String.self) { post, username in
                post.username = username
            },
            UpdateableKey(UserTemp.Keys.age, Int.self) { post, age in
                post.age = age
            }
        ]
    }
}


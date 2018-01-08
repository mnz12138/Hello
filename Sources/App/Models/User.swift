import Vapor
import FluentProvider
import Routing

final class User: Model {
    let storage = Storage()
    
    var userid: Int = 0
    var username: String
    
    /// The column names for `id` and `content` in the database
    struct Keys {
        static let userid = "user_id"
        static let username = "user_name"
    }
    
    init(username: String) {
        self.username = username
    }
    
    /// Creates a new Post
    init(userid: Int, username: String) {
        self.userid = userid
        self.username = username
    }
    
    // MARK: Fluent Serialization
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        userid = try row.get(User.Keys.userid)
        username = try row.get(User.Keys.username)
    }
    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(User.Keys.userid, userid)
        try row.set(User.Keys.username, username)
        return row
    }
}

extension User: Preparation {
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.int(User.Keys.userid)
            builder.string(User.Keys.username)
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
extension User: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            userid: try json.get(User.Keys.userid),
            username: try json.get(User.Keys.username)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(User.Keys.userid, userid)
        try json.set(User.Keys.username, username)
        return json
    }
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures
extension User: ResponseRepresentable { }

extension User: Updateable {
    public static var updateableKeys: [UpdateableKey<User>] {
        return [
            UpdateableKey(User.Keys.userid, Int.self) { post, userid in
                post.userid = userid
            },
            UpdateableKey(User.Keys.username, String.self) { post, username in
                post.username = username
            }
        ]
    }
}

extension User: Parameterizable {
    /// This unique slug is used to identify
    /// the parameter in the router
    static var uniqueSlug: String {
        return "user"
    }
    
    static func make(for parameter: String) throws -> User {
        /// custom lookup logic here
        /// the parameter string contains the information
        /// parsed from the URL.
        guard let user_id = parameter.int else {
            throw Abort.badRequest
        }
        return try UserManager.queryUser(userid: user_id) ?? User(userid: -1, username: "")
    }
}

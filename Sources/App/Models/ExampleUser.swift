import Vapor
import FluentProvider
import AuthProvider

final class ExampleUser: Model {
    let storage = Storage()
    
    var username: String = ""
    
    struct Keys {
        static let userid = "user_id"
        static let username = "user_name"
    }
    
    init(username: String) {
        self.username = username
    }
    
    init(row: Row) throws {
        username = try row.get(ExampleUser.Keys.username)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(ExampleUser.Keys.username, username)
        return row
    }

}

extension ExampleUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(ExampleUser.Keys.username)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension ExampleUser: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            username: try json.get(ExampleUser.Keys.username)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(ExampleUser.Keys.userid, id)
        try json.set(ExampleUser.Keys.username, username)
        return json
    }
}

extension ExampleUser: TokenAuthenticatable {
    // the token model that should be queried
    // to authenticate this user
    public typealias TokenType = ExampleToken
}

extension ExampleUser: PasswordAuthenticatable {
    
    ///返回匹配所提供的
    ///用户名和密码的用户
    static func authenticate(password: Password) throws -> ExampleUser {
        // something custom
        return ExampleUser(username: "")
    }

    public static var usernameKey: String {
        return "usernameKey"
    }
    
    public static var passwordKey: String {
        return "passwordKey"
    }
    
    ///实体的哈希密码用于
    ///验证密码凭证
    ///使用PasswordVerifier
    public var hashedPassword: String? {
        return nil
    }
    
    ///可选密码验证器在
    ///比较来自
    ///授权标头的
    ///明文密码与数据库中的
    ///散列密码///时使用
    public static var passwordVerifier: ExampleUser? {
        return nil
    }
    
}

//如果你的用户是Model，协议方法将自动实现。不过，如果你想做一些自定义的事情，你可以实现它们。
extension ExampleUser: SessionPersistable {
    func persist(for: Request) throws {
        // something custom
    }
    
    static func fetchPersisted(for: Request) throws -> ExampleUser? {
        // something custom
        return nil
    }
}


import JSON

final class UserManager {
    
    class func queryAllUser() throws -> [User] {
        let node = try SharedConnection.sharedInstance.connection.execute("select * from users")
        var array: [User] = [User]()
        guard let nodes = node.array else {
            return []
        }
        for n in nodes {
            let json = JSON(n.wrapped, n.context)
            let user = try User(json: json)
            array.append(user)
        }
        return array
    }
    
    class func queryUser(userid: Int) throws -> User? {
        let node = try SharedConnection.sharedInstance.connection.execute("select * from users where user_id=\(userid)")
        guard let first_node = node.array?.first else {
            return nil
        }
        let json = JSON(first_node.wrapped, first_node.context)
        return try User(json: json)
    }
    
    class func save(username: String) throws -> Int {
        let usernameNode = username.makeNode(in: nil)
        try SharedConnection.sharedInstance.connection.execute("insert into users(user_name) values (?);",[usernameNode])
        let node = try SharedConnection.sharedInstance.connection.execute("select @@identity as user_id;")
        //select max(user_id) from users;
        guard let first_node = node.array?.first,
            let user_id = first_node["user_id"]?.int else {
            return -1
        }
        return user_id
    }
    
}

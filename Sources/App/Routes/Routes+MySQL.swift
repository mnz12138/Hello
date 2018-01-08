import Vapor

extension Droplet {

    func setupMySQLRoutes() throws {
        
        get("mysql/version") { (request) -> ResponseRepresentable in
            let node = try self.mysql().raw("SELECT @@version")
            return JSON(node)
        }
        
        get("mysql/userlist") { request in
            let node = try self.mysql().raw("select * from users")
            var array: [User] = [User]()
            guard let nodes = node.array else {
                return try array.makeJSON()
            }
            for n in nodes {
                let json = JSON(n.wrapped, n.context)
                let user = try User(json: json)
                array.append(user)
            }
            return try array.makeJSON()
        }
        
        get("mysql/usertemplist") { request in
            let query = try UserTemp.makeQuery()
            return try query.all().makeJSON()
        }
        
    }
    
}

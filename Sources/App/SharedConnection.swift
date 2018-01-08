import MySQL

//手动连接数据库
final class SharedConnection {
    
    class var sharedInstance: SharedConnection {
        struct Static {
            static let instance = SharedConnection()
        }
        return Static.instance
    }
    
    var mysql: Database
    var connection: Connection
    init() {
        do {
            mysql = try Database(hostname:"localhost",
                                 user:"root",
                                 password:"123456",
                                 database:"vapor")
            connection = try mysql.makeConnection()
            try connection.execute("SELECT @@version")
            print("数据库连接成功")
        } catch {
            print("Unable to connect to MySQL:  \(error)")
            exit(-1)
        }
    }
}

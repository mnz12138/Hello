import Vapor
import FluentProvider
import MySQLProvider
import RedisProvider
import AuthProvider
import LeafProvider
//import VaporMustache

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        //不用配置文件
        //let mysqlProvider = VaporMySQL.Provider(host: "localhost", user: "root", password: "123456", database: "vapor")
//        try addProvider(mysqlProvider)
        //有配置文件
        //fluent.json ("driver": "memory",->"driver": "mysql",)
        //droplet.json 您也可以选择使用您的Fluent数据库（现在设置为MySQL）进行缓存。("driver": "fluent",)
        //可以通过传递一个master主机名和一组readReplicas主机名来提供读取副本
        /*
         "master" ： "master.mysql.foo.com",
         "readReplicas": ["read01.mysql.foo.com", "read02.mysql.foo.com" ]，
         "user": "root",
         "password": "123456",
         "database": "vapor"
         */
        //droplet.mysql().raw("SELECT @@version");
        try addProvider(MySQLProvider.Provider.self)
        //Config/droplet.json ("cache": "redis")
        try addProvider(RedisProvider.Provider.self)
        //
        try addProvider(AuthProvider.Provider.self)
        //使用Leaf view渲染器
        try addProvider(LeafProvider.Provider.self)
        
        //可以返回模板视图
//        try addProvider(VaporMustache.Provider.self)
        
        //版本中间件 droplet.json ("middleware": ["version"])
        addConfigurable(middleware: VersionMiddleware(), name: "version")
        //自定义错误中间件
        addConfigurable(middleware: FooErrorMiddleware(), name: "foo-error")
        
        //跨源资源共享CORSMiddleware
        let cors = CORSConfiguration(allowedOrigin: .custom("https://vapor.codes"), allowedMethods: [.get, .post, .options], allowedHeaders: ["Accept", "Authorization"], allowCredentials: false, cacheExpiration: 600, exposedHeaders: ["Cache-Control", "Content-Language"])
        addConfigurable(middleware: CORSMiddleware(configuration: cors), name: "custom-cors")
    }
    
    /// Add all models that should have their
    /// schemas prepazhong'gred before the app boots
    private func setupPreparations() throws {
        preparations.append(Post.self)
        preparations.append(UserTemp.self)
        preparations.append(ExampleUser.self)
        preparations.append(ExampleToken.self)
    }
}

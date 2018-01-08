import Vapor
import FluentProvider

final class Pokemon: Model {
    let storage = Storage()
    
    let name: String
    
    struct Keys {
        static let id = "id"
        static let name = "name"
    }
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get(Pokemon.Keys.name)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set(Pokemon.Keys.name, name)
        return row
    }
    
}

extension Pokemon: JSONConvertible {
    convenience init(json: JSON) throws {
        self.init(
            name: try json.get(Pokemon.Keys.name)
        )
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set(Pokemon.Keys.id, id)
        try json.set(Pokemon.Keys.name, name)
        return json
    }
}

extension Pokemon: Preparation {
    
    /// Prepares a table/collection in the database
    /// for storing Posts
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string(Pokemon.Keys.name)
        }
    }
    
    /// Undoes what was done in `prepare`
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
    
}

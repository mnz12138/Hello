
extension Response {
    var pokemon: Pokemon? {
        get { return storage["pokemon"] as? Pokemon }
        set { storage["pokemon"] = newValue }
    }
}

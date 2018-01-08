import HTTP

//扩展请求响应头
extension HTTP.KeyAccessible where Key == HeaderKey, Value == String {
    var customKey: String? {
        get {
            return self["Custom-Key"]
        }
        set {
            self["Custom-Key"] = newValue
        }
    }
}


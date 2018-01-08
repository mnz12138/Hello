import Validation

//自定义验证器
class NameValidationSuite: Validator {
    typealias Input = String
    let onlyAlphanumeric = OnlyAlphanumeric()
    func validate(_ input: NameValidationSuite.Input) throws {
        //字母或数字
        try onlyAlphanumeric.validate(input)
        let passed = input.passes(Count.containedIn(low: 5, high: 20))
        if !passed {
            throw error("\(input) is not alphanumeric or character number [5,20].")
        }
    }
}


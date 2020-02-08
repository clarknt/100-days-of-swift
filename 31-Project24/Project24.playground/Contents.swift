import UIKit

let name = "Taylor"

for letter in name {
    print("Give me a \(letter)!")
}

// not compiling
//print(name[3])

let letter = name[name.index(name.startIndex, offsetBy: 3)]

extension String {
    // not ok performance wise
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

let letter2 = name[3]

let password = "12345"
password.hasPrefix("123")
password.hasSuffix("345")

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func deletingSuffix(_ suffix: String) -> String {
        guard self.hasSuffix(suffix) else { return self }
        return String(self.dropLast(suffix.count))
    }
}

let weather = "it's going to rain"
print(weather.capitalized)

extension String {
    var capitalizedFirst: String {
        guard let firstLetter = self.first else { return "" }
        return firstLetter.uppercased() + self.dropFirst()
    }
}

let input = "Swift is like Objective-C without the C"
input.contains("Swift")

let languages = ["Python", "Ruby", "Swift"]
languages.contains("Swift")

extension String {
    func containsAny(of array: [String]) -> Bool {
        for item in array {
            if self.contains(item) {
                return true
            }
        }
        
        return false
    }
}

input.containsAny(of: languages)

// better solution
languages.contains(where: input.contains)
// which is a shortcut for
languages.contains { currentString in
    return input.contains(currentString)
}

let string = "This is a test string"

let attributes: [NSAttributedString.Key: Any] = [
    .foregroundColor: UIColor.white,
    .backgroundColor: UIColor.red,
    .font: UIFont.boldSystemFont(ofSize: 36)
]

let attributedString = NSAttributedString(string: string, attributes: attributes)

let attributedString2 = NSMutableAttributedString(string: string)
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 8), range: NSRange(location: 0, length: 4))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 16), range: NSRange(location: 5, length: 2))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 24), range: NSRange(location: 8, length: 1))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 32), range: NSRange(location: 10, length: 4))
attributedString2.addAttribute(.font, value: UIFont.systemFont(ofSize: 40), range: NSRange(location: 15, length: 6))

// challenge 1
extension String {
    func withPrefix(_ prefix: String) -> String {
        guard !self.hasPrefix(prefix) else { return self }
        return prefix + self
    }
}

assert("test".withPrefix("te") == "test")
assert("pet".withPrefix("car") == "carpet")

// challenge 2
extension String {
    var isNumeric: Bool {
        return Double(self) != nil
    }
}

assert("test".isNumeric == false)
assert("123".isNumeric == true)
assert("456.7".isNumeric == true)

// challenge 3
extension String {
    var lines: [Substring] {
        return self.split(separator: "\n")
    }
}

assert("this\nis\na\ntest".lines == ["this", "is", "a", "test"])

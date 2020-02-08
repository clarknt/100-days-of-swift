import UIKit
import PlaygroundSupport

// challenge 1
extension UIView {
    func bounceOut(duration: TimeInterval) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.0001, y: 0.0001)
        }
    }
}

// use "View -> Assistant Editor -> Show Assistant Editor" or "CMD-OPT-<enter>" to display the view in the playground
let view = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 350, height: 350)))
view.backgroundColor = .white

let label = UILabel()
label.font = UIFont.systemFont(ofSize: 38)
label.text = "ANIMATION"
label.translatesAutoresizingMaskIntoConstraints = false
label.textAlignment = .center
view.addSubview(label)

NSLayoutConstraint.activate([
    label.leadingAnchor.constraint(equalTo: view.leadingAnchor), label.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    label.topAnchor.constraint(equalTo: view.topAnchor), label.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])

PlaygroundPage.current.liveView = view
label.bounceOut(duration: 3)



// challenge 2
extension Int {
    func times(handler: () -> Void) {
        guard self > 0 else { return }
        for _ in 1...self {
            handler()
        }
    }
}

5.times { print("Hello!") }

var counter = 0
5.times { counter += 1 }
assert(counter == 5)

let count = -5
count.times { print("No crash") }

// challenge 3
extension Array where Element: Comparable {
    mutating func remove(item: Element) {
        if let index = self.firstIndex(of: item) {
            remove(at: index)
        }
    }
}

// nominal case
var test1 = [1, 2, 3]
test1.remove(item: 3)
assert(test1 == [1, 2])

// unknown element
var test2 = [String]()
test2.remove(item: "unknown")
assert(test2 == [String]())

// multiple times the same element
var test3 = [1, 2, 1]
test3.remove(item: 1)
assert(test3 == [2, 1])

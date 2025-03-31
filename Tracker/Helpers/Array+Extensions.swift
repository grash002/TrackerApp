import Foundation

extension Array {
    func partitioned(by condition: (Element) -> Bool) -> (matched: [Element], unmatched: [Element]) {
        var matched = [Element]()
        var unmatched = [Element]()
        for element in self {
            if condition(element) {
                matched.append(element)
            } else {
                unmatched.append(element)
            }
        }
        return (matched, unmatched)
    }
}

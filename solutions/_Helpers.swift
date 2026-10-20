// Shared helpers for every solution file. Not part of any LeetCode submission.

/// Prints ✅ or ❌ with the line number of the test.
func check<T: Equatable>(_ got: T, _ want: T, line: Int = #line) {
    print(got == want ? "✅ line \(line)" : "❌ line \(line): got \(got), want \(want)")
}

// MARK: - LeetCode's built-in types (same definitions LeetCode uses)

public class ListNode {
    public var val: Int
    public var next: ListNode?
    public init() { self.val = 0; self.next = nil }
    public init(_ val: Int) { self.val = val; self.next = nil }
    public init(_ val: Int, _ next: ListNode?) { self.val = val; self.next = next }
}

public class TreeNode {
    public var val: Int
    public var left: TreeNode?
    public var right: TreeNode?
    public init() { self.val = 0; self.left = nil; self.right = nil }
    public init(_ val: Int) { self.val = val; self.left = nil; self.right = nil }
    public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
        self.val = val
        self.left = left
        self.right = right
    }
}

// MARK: - Builders for test cases

/// list([2, 4, 3]) → 2 -> 4 -> 3
func list(_ values: [Int]) -> ListNode? {
    let dummy = ListNode()
    var tail = dummy
    for v in values {
        tail.next = ListNode(v)
        tail = tail.next!
    }
    return dummy.next
}

/// array(of: head) → [2, 4, 3], handy for check(...)
func array(of head: ListNode?) -> [Int] {
    var result: [Int] = []
    var node = head
    while let n = node {
        result.append(n.val)
        node = n.next
    }
    return result
}

/// tree([3, 9, 20, nil, nil, 15, 7]) builds a tree from LeetCode's level-order format.
func tree(_ values: [Int?]) -> TreeNode? {
    guard let first = values.first, let rootVal = first else { return nil }
    let root = TreeNode(rootVal)
    var queue = [root]
    var i = 1
    while i < values.count, !queue.isEmpty {
        let node = queue.removeFirst()
        if let v = values[i] { node.left = TreeNode(v); queue.append(node.left!) }
        i += 1
        if i < values.count, let v = values[i] { node.right = TreeNode(v); queue.append(node.right!) }
        i += 1
    }
    return root
}

/// levelOrder(of: root) → [3, 9, 20, nil, nil, 15, 7], the inverse of tree(_:)
func levelOrder(of root: TreeNode?) -> [Int?] {
    var result: [Int?] = []
    var queue: [TreeNode?] = [root]
    while !queue.isEmpty {
        let node = queue.removeFirst()
        result.append(node?.val)
        if let node { queue.append(node.left); queue.append(node.right) }
    }
    while result.last == .some(nil) { result.removeLast() }
    return result
}

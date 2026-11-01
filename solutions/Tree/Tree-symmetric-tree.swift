// Symmetric Tree
// Easy · Tree, Depth-First Search, Breadth-First Search, Binary Tree
// https://leetcode.com/problems/symmetric-tree
// Picked from: —
//
// Approach:
//
// Time:  O(?)
// Space: O(?)
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("Symmetric Tree") {
    class Solution {

        // MARK: Solution 1 - Recursive
        func isSymmetric2(_ root: TreeNode?) -> Bool {

            guard let root = root else { return false }

            return isMirror(root.left, root.right)
        }

        private func isMirror(_ a: TreeNode?, _ b: TreeNode?) -> Bool {
            guard let a, let b else { return a == nil && b == nil }
            return a.val == b.val
                && isMirror(a.left, b.right)
                && isMirror(a.right, b.left)
        }

        // MARK: Solution 2 - Interative
        func isSymmetric(_ root: TreeNode?) -> Bool {
            var queue: [(TreeNode?, TreeNode?)] = [(root?.left, root?.right)]
            var i: Int = 0

            while i < queue.count {
                let (a, b) = queue[i]
                i += 1

                if a == nil && b == nil { continue }
                guard let a, let b, a.val == b.val else {
                    return false
                }

                queue.append((a.left, b.right))
                queue.append((a.right, b.left))
            }

            return true
        }
    }

    let s = Solution()
    check(s.isSymmetric(tree([1, 2, 2, 3, 4, 4, 3])), true)
    check(s.isSymmetric(tree([1, 2, 2, nil, 3, nil, 3])), false)
}

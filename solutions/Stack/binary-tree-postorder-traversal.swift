// Binary Tree Postorder Traversal
// Easy · Stack, Tree, Depth-First Search, Binary Tree
// https://leetcode.com/problems/binary-tree-postorder-traversal
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

#Playground("Binary Tree Postorder Traversal") {
    class Solution {

        // Input: TreeNode?
        // Output: [Int]

        // Plan:
        //  - from root
        //  -  go the the node's leaf of all child's node
        //  -  use stack to store node that still not check

        func postorderTraversal(_ root: TreeNode?) -> [Int] {
            guard let root = root else { return [] }
            var results: [Int] = []
            var stack: [(node: TreeNode, visited: Bool)] = [(root, false)]

            while let (node, visited) = stack.popLast() {
                if visited {
                    results.append(node.val)
                } else {
                    stack.append((node, true))
                    if let right = node.right { stack.append((right, false)) }
                    if let left = node.left { stack.append((left, false)) }
                }
            }

            return results
        }

        // Implement:
        // root: 1
        // leaf: 2, 3 -> stack = [1, 3, 2]

        // root: 2
        // leaf: 4, 5 -> stack = [1, 3, 2, 5, 4]
        // node 4: -> final leaf
        // results = [4]

        // root: 5
        // leaf: 6, 7 -> stack = [1, 3, 2, 5, 7, 6]
        // results = [4, 6, 7]
        // results = [4, 6, 7, 5, 2]
        // stack = [1, 3]

        // root = 3
    }

    let s = Solution()
    check(s.postorderTraversal(tree([1, nil, 2, 3])), [3, 2, 1])
        check(s.postorderTraversal(tree([1,2,3,4,5,nil,8,nil,nil,6,7,9])), [4,6,7,5,2,9,8,3,1])
        check(s.postorderTraversal(tree([])), [])
        check(s.postorderTraversal(tree([1])), [1])
}

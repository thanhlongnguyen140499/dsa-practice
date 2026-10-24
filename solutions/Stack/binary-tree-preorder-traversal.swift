// Binary Tree Preorder Traversal
// Easy · Stack, Tree, Depth-First Search, Binary Tree
// https://leetcode.com/problems/binary-tree-preorder-traversal
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

#Playground("Binary Tree Preorder Traversal") {
    class Solution {

        // Input: TreeNode?
        // Out: [Int]

        // Plan
        //  - Go from root,
        //  - check left and right -> add to stack
        //      + if left is available: -> check node's left/right -> add to stack
        //      + if right is available -> ...
        // - to the end: stack remove last().

        // Expected: clean stack -> return array of int

        func preorderTraversal(_ root: TreeNode?) -> [Int] {
            guard let root = root else { return [] }
            
            var stack: [TreeNode] = [root]
            var results: [Int] = []
            
            while let node = stack.popLast() {
                results.append(node.val)

                if let right = node.right {
                    stack.append(right)
                }
                if let left = node.left {
                    stack.append(left)
                }
            }

            return results
        }
    }

    let s = Solution()
    check(s.preorderTraversal(tree([1, nil, 2, 3])), [1, 2, 3])
    check(
        s.preorderTraversal(tree([1, 2, 3, 4, 5, nil, 8, nil, nil, 6, 7, 9])),
        [1, 2, 4, 5, 6, 7, 3, 8, 9]
    )
    check(s.preorderTraversal(tree([])), [])
    check(s.preorderTraversal(tree([1])), [1])
}

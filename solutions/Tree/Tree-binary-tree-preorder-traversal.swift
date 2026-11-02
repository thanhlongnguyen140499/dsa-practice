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

        // MARK: Solution 1 - Using stack at Stack-binary-tree-preorder-traversal

        // MARK: Solution 2 - Using recursion
        func preorderTraversal(_ root: TreeNode?) -> [Int] {
            var results: [Int] = []

            func dfs(_ node: TreeNode?) {
                guard let node else { return }
                
                results.append(node.val)
                dfs(node.left)
                dfs(node.right)
            }

            dfs(root)

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

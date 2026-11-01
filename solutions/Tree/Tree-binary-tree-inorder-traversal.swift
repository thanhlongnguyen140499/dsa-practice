// Binary Tree Inorder Traversal
// Easy · Stack, Tree, Depth-First Search, Binary Tree
// https://leetcode.com/problems/binary-tree-inorder-traversal
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

#Playground("Binary Tree Inorder Traversal") {
    class Solution {
        func inorderTraversal(_ root: TreeNode?) -> [Int] {
            var results: [Int] = []

            func dfs(_ node: TreeNode?) {
                guard let node = node else { return }
                dfs(node.left)
                results.append(node.val)
                dfs(node.right)
            }

            dfs(root)
            return results
        }
    }

    let s = Solution()
    check(s.inorderTraversal(tree([1, nil, 2, 3])), [1, 3, 2])
    //    check(s.inorderTraversal(tree([1,2,3,4,5,nil,8,nil,nil,6,7,9])), [4,2,6,5,7,1,3,9,8])
    //    check(s.inorderTraversal(tree([])), [])
    //    check(s.inorderTraversal(tree([1])), [1])
}

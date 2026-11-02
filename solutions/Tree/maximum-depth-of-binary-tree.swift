// Maximum Depth of Binary Tree
// Easy · Tree, Depth-First Search, Breadth-First Search, Binary Tree
// https://leetcode.com/problems/maximum-depth-of-binary-tree
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

#Playground("Maximum Depth of Binary Tree") {
    class Solution {

        // Input: Tree
        // Output: Int

        // Plan:
        // e.g: [3, 9, 20, nil, nil, 15, 7]
        // 3
        // 9 20
        //  15 7

        // - Check each branch until reach end node
        func maxDepth(_ root: TreeNode?) -> Int {
            guard let root = root else { return 0 }

            let leftDepth = maxDepth(root.left)
            let rightDepth = maxDepth(root.right)

            return max(leftDepth, rightDepth) + 1
        }
    }

    let s = Solution()
    check(s.maxDepth(tree([3, 9, 20, nil, nil, 15, 7])), 3)
    check(s.maxDepth(tree([1, nil, 2])), 2)
}

// Same Tree
// Easy · Tree, Depth-First Search, Breadth-First Search, Binary Tree
// https://leetcode.com/problems/same-tree
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

#Playground("Same Tree") {
    class Solution {
        // Input: 2 TreeNode
        // Output: True / False

        // Plan:
        // - True:
        //   + Same structure
        //   + Each node is same value

        // - Walk through all nodes and check value
        func isSameTree(_ p: TreeNode?, _ q: TreeNode?) -> Bool {

            if p == nil, q == nil {
                return true
            }

            if p?.val == q?.val,
                isSameTree(p?.left, q?.left),
                isSameTree(p?.right, q?.right)
            {
                return true
            }

            return false
        }
    }

    let s = Solution()
    check(s.isSameTree(tree([1, 2, 3]), tree([1, 2, 3])), true)
    //    check(s.isSameTree(tree([1,2]), tree([1,nil,2])), false)
    //    check(s.isSameTree(tree([1,2,1]), tree([1,1,2])), false)
}

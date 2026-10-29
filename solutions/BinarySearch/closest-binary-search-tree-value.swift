// Closest Binary Search Tree Value
// Easy · Binary Search, Tree, Depth-First Search, Binary Search Tree, Binary Tree
// https://leetcode.com/problems/closest-binary-search-tree-value
// Free version: https://www.lintcode.com/problem/900/
// Picked from: —
//
// Approach: Walk down the BST like a binary search, going left or right toward the target,
//           and keep the closest value seen (the smaller one on a tie).
//
// Time:  O(h), h = tree height (O(log n) balanced, O(n) skewed)
// Space: O(1)
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("Closest Binary Search Tree Value") {
    class Solution {
        // Given the root of a BST and a target value, return the value in the BST
        // that is closest to the target. If there are multiple answers, return the smallest.
        // Plan:
        //  - BST: left < node < right → walk down like binary search
        //  - at each node, keep it if it's closer than the best so far
        //    (on a tie, keep the smaller value)
        //  - target < node → go left, else go right

        func closestValue(_ root: TreeNode?, _ target: Double) -> Int {
            guard let root else { return 0 }

            var current: TreeNode? = root
            var closest: Int = current?.val ?? 0

            while let node = current {
                let diff = abs(Double(node.val) - target)
                let best = abs(Double(closest) - target)

                if diff < best || (diff == best && node.val < closest) {
                    closest = node.val
                }

                current = Int(target) <= node.val ? node.left : node.right
            }

            // Todo: update
            return closest
        }
    }

    let s = Solution()
    check(s.closestValue(tree([4, 2, 5, 1, 3]), 3.714286), 4)
    check(s.closestValue(tree([1]), 4.428571), 1)
    check(s.closestValue(tree([4, 2, 5, 1, 3]), 3.5), 3)  // tie → smaller
    check(s.closestValue(tree([1, nil, 2]), 3.0), 2)
}

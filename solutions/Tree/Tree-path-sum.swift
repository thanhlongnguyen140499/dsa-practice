// Path Sum
// Easy · Tree, Depth-First Search, Breadth-First Search, Binary Tree
// https://leetcode.com/problems/path-sum
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

#Playground("Path Sum") {
    class Solution {
        // Input: a Tree + target
        // Output: True/False

        // Plan:
        // - root + child note's left / right + ... = targetSum

        // MARK: Solution 1 - Recursive DFS (Recommended)
        // Time & Space Complexity
        // Time: O(n) - visit each node once
        // Space: O(n) - recursion stack
        func hasPathSum(_ root: TreeNode?, _ targetSum: Int) -> Bool {
            guard let root else { return false }

            if root.left == nil && root.right == nil {
                return targetSum - root.val == 0
            }

            let remain = targetSum - root.val

            return hasPathSum(root.left, remain)
                || hasPathSum(root.right, remain)
        }
        
        // MARK: Solution 2 - Iterative DFS (using Stack)
        // Time & Space Complexity
        // Time: O(n)
        // Space: O(n)
        func hasPathSum2(_ root: TreeNode?, _ targetSum: Int) -> Bool {
            guard let root else { return false }
            
            // Stack stores (node, remainingSum)
            var stack: [(TreeNode, Int)] = [(root, targetSum - root.val)]
            
            while !stack.isEmpty {
                let (node, remain) = stack.removeLast()
                
                // Check if it's a leaf and remaining sum is 0
                if node.left == nil && node.right == nil && remain == 0 {
                    return true
                }
                
                if let right = node.right {
                    stack.append((right, remain - right.val))
                }
                if let left = node.left {
                    stack.append((left, remain - left.val))
                }
            }
            
            return false
        }
        
        // MARK: Solution 3 - BFS (using Queue)
        // Time & Space Complexity
        // Time: O(n)
        // Space: O(n) (width of the tree)
        func hasPathSum3(_ root: TreeNode?, _ targetSum: Int) -> Bool {
            guard let root else { return false }
            
            // Queue stores (node, remainingSum)
            var queue: [(TreeNode, Int)] = [(root, targetSum - root.val)]
            
            while !queue.isEmpty {
                let (node, remain) = queue.removeFirst()
                
                // Leaf node with remaining sum == 0
                if node.left == nil && node.right == nil && remain == 0 {
                    return true
                }
                
                if let left = node.left {
                    queue.append((left, remain - left.val))
                }
                if let right = node.right {
                    queue.append((right, remain - right.val))
                }
            }
            
            return false
        }
    }

    let s = Solution()
    check(
        s.hasPathSum(
            tree([5, 4, 8, 11, nil, 13, 4, 7, 2, nil, nil, nil, 1]),
            22
        ),
        true
    )
    check(s.hasPathSum(tree([1, 2, 3]), 5), false)
    check(s.hasPathSum(tree([]), 0), false)
}

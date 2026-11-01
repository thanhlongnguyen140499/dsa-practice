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

/**
 * Definition for a binary tree node.
 * public class TreeNode {
 *     public var val: Int
 *     public var left: TreeNode?
 *     public var right: TreeNode?
 *     public init() { self.val = 0; self.left = nil; self.right = nil; }
 *     public init(_ val: Int) { self.val = val; self.left = nil; self.right = nil; }
 *     public init(_ val: Int, _ left: TreeNode?, _ right: TreeNode?) {
 *         self.val = val
 *         self.left = left
 *         self.right = right
 *     }
 * }
 */
#Playground("Binary Tree Inorder Traversal") {
    class Solution {

        // Input: TreeNode
        // Output: Array of int

        // Notes;
        // - rely on Tree node to fill value like explaination
        // - will return an [Int] which is read from:
        //  + left -> right
        //  + top -> bottom

        // - using Stack (LIFO: last in, first out)

        // Try:
        // TreeNode:            1
        //              nil         2
        //                      3
        // Stack:
        //      layer1: val = 1, stack = [ 1 ]
        //      layer2: check
        //      loop3: stack =

        func inorderTraversal(_ root: TreeNode?) -> [Int] {
            var results: [Int] = []
            var stack: [TreeNode] = []
            var current = root

            while current != nil || !stack.isEmpty {

                // Step1: go left to the end
                while let node = current {
                    stack.append(node)
                    current = node.left
                }

                // Step2: reach end left, add to results
                let node = stack.removeLast()
                results.append(node.val)

                // Step3: go right
                current = node.right
            }

            return results
        }
    }

    let s = Solution()
    check(s.inorderTraversal(tree([1, nil, 2, 3])), [1, 3, 2])
    check(
        s.inorderTraversal(tree([1, 2, 3, 4, 5, nil, 8, nil, nil, 6, 7, 9])),
        [4, 2, 6, 5, 7, 1, 3, 9, 8]
    )
    check(s.inorderTraversal(tree([])), [])
    check(s.inorderTraversal(tree([1])), [1])
}

// Find Center of Star Graph
// Easy · Graph Theory
// https://leetcode.com/problems/find-center-of-star-graph
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

#Playground("Find Center of Star Graph") {
    class Solution {
        // Input: 2D array
        // Output: a number

        // Plan:
        // - Star graph: the center is in EVERY edge, each leaf is in exactly ONE edge
        //   → any two edges share exactly one node = the center
        // - Constraint "valid star graph" → no need to scan the rest
        // 1. Take the first two edges: a = edges[0], b = edges[1]
        // 2. Candidates for the center are a[0] and a[1]
        // 3. If a[0] appears in b (a[0] == b[0] || a[0] == b[1]) → center is a[0]
        // 4. Otherwise → center is a[1]
        // e.g. [[1,2],[5,1],...]: 1 is in [5,1] → 1
        //      [[1,2],[2,3],...]: 1 not in [2,3] → 2
        // Alternative: count degrees, return the node with degree n-1 (O(n))

        // Time & Space Complexity
        // Time: O(1) - only reads two edges
        // Space: O(1)
        func findCenter(_ edges: [[Int]]) -> Int {

            let a = edges[0]
            let b = edges[1]

            return (a[0] == b[0] || a[0] == b[1]) ? a[0] : a[1]
        }
    }

    let s = Solution()
    //    check(s.findCenter([[1, 2], [2, 3], [4, 2]]), 2)
    check(s.findCenter([[1, 2], [5, 1], [1, 3], [1, 4]]), 1)
}

// Finding 3-Digit Even Numbers
// Easy · Array, Hash Table, Recursion, Sorting, Enumeration
// https://leetcode.com/problems/finding-3-digit-even-numbers
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

#Playground("Finding 3-Digit Even Numbers") {
    class Solution {
        
        // Input: [Int]
        // Output: sorted [Int] is 3-digit EVEN number
        
        // Plan:
        // - sort digits array
        // - use recursion to find outs
        
        // [3, 7, 5] -> sorted -> [3, 5, 7]
        // 3 5 7
        // 3 7 5
        // 5 3 7
        // 5 7 3
        // 7 3 5
        // 7 5 3
        
        func findEvenNumbers(_ digits: [Int]) -> [Int] {
            return []
        }
    }

    let s = Solution()
//    check(
//        s.findEvenNumbers([2, 1, 3, 0]),
//        [102, 120, 130, 132, 210, 230, 302, 310, 312, 320]
//    )
//    check(
//        s.findEvenNumbers([2, 2, 8, 8, 2]),
//        [222, 228, 282, 288, 822, 828, 882]
//    )
    check(s.findEvenNumbers([3, 7, 5]), [])
}

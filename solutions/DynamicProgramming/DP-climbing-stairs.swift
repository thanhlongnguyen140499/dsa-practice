// Climbing Stairs
// Easy · Math, Dynamic Programming, Memoization
// https://leetcode.com/problems/climbing-stairs
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

#Playground("Climbing Stairs") {
    class Solution {

        // Input: Int
        // Output: Int

        // Plan:
        // - Using DP to save

        // MARK: Solution 1 - Recursion + Cache
        // Big O(n)
        var memo: [Int: Int] = [:]
        var result: Int = 0

        func climbStairs1(_ n: Int) -> Int {
            if n <= 2 { return n }

            if let saved = memo[n] { memo[n] }
            result = climbStairs(n - 1) + climbStairs(n - 2)

            return result
        }

        // MARK 2: Solution - bottom-up tabulation
        // Big O(n)
        // Plan:
        //  - Save values to table
        func climbStairs(_ n: Int) -> Int {
            if n <= 2 { return n }

            var table = [Int](repeating: 0, count: n + 1)
            table[1] = 1
            table[2] = 2

            for i in 3..<n + 1 {
                table[i] = table[i - 1] + table[i - 2]
            }

            return table[n]
        }
    }

    let s = Solution()
    check(s.climbStairs(2), 2)
    check(s.climbStairs(3), 3)
    check(s.climbStairs(4), 5)
}

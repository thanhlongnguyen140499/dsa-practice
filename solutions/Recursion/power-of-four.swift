// Power of Four
// Easy · Math, Bit Manipulation, Recursion
// https://leetcode.com/problems/power-of-four
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

#Playground("Power of Four") {

    // Input: int
    // Output: true/false

    // Plan:
    // - Using recursion to find out
    //  power of 2 is power of 4
    //  1 = 2^1
    //  4 = 2^2
    //  8 = 2^3
    // 12 = 2^3 + 2^2
    // 16 = 2^4
    // 20 = 2^4 + 2^2
    // 24 = 2^5
    class Solution {
        func isPowerOfFour(_ n: Int) -> Bool {
            if n <= 0 { return false }
            if n == 1 { return true }
            if n % 4 != 0 { return false }

            return isPowerOfFour(n / 4)
        }
    }

    let s = Solution()
    check(s.isPowerOfFour(16), true)
    check(s.isPowerOfFour(5), false)
    check(s.isPowerOfFour(1), true)
}

// Power of Three
// Easy · Math, Recursion
// https://leetcode.com/problems/power-of-three
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

#Playground("Power of Three") {
    class Solution {

        // Time: O(log n)
        // Space: O(log n)

        // 27
        // -> isPowerOfThree(27 / 3) = 9
        // -> isPowerOfThree(9 / 3) = 3
        // -> isPowerOfThree(3 / 3) = 1 => true
        func isPowerOfThree(_ n: Int) -> Bool {
            if n <= 0 { return false }  // 0 and negatives
            if n == 1 { return true }  // base case: 3⁰
            if n % 3 != 0 { return false }  // not divisible by 3, can't be a power of three
            return isPowerOfThree(n / 3)  // recurse on the smaller problem
        }
    }

    let s = Solution()
    check(s.isPowerOfThree(27), true)
    check(s.isPowerOfThree(0), false)
    check(s.isPowerOfThree(-1), false)
}

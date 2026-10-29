// Power of Two
// Easy · Math, Bit Manipulation, Recursion
// https://leetcode.com/problems/power-of-two
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

#Playground("Power of Two") {
    class Solution {

        // MARK: First Solution
        // Time: O(log n)
        // Space: O(log n)

        // 16
        // -> isPowerOfTwo(n / 2) = 8
        // -> isPowerOfTwo(n / 2) = 4
        //      isPowerOfTwo(n/2) = 2
        //      isPowerOfTwo(n/2) = 1 => true

        func isPowerOfTwo2(_ n: Int) -> Bool {
            if n <= 0 { return false }  // 0 and negatives
            if n == 1 { return true }  // base case: 2⁰
            if n % 2 != 0 { return false }  // odd > 1 can't be a power of two
            return isPowerOfTwo(n / 2)  // recurse on the smaller problem
        }

        // MARK: BEST PRACTICE:
        // Time: O(1)
        // Space: O(1)

        // Using binary to compare:
        //  1.only have one (1) available in binary
        //        1  = 00001
        //        2  = 00010
        //        4  = 00100
        //        8  = 01000
        //        16 = 10000

        // 2. Subtracting 1 flips the lowest 1 bit and every bit to its right. It works like borrowing in decimal subtraction (1000 − 1 = 999):

        // 16 = 1000
        // 15 = 0111
        // 16 & 15 = 0000 => True

        // 10 = 1010
        //  9 = 1001
        // 10 & 9 = 1011 => False
        func isPowerOfTwo(_ n: Int) -> Bool {
            n > 0 && (n & (n - 1)) == 0
        }
    }

    let s = Solution()
    check(s.isPowerOfTwo(1), true)
    check(s.isPowerOfTwo(16), true)
    check(s.isPowerOfTwo(3), false)
}

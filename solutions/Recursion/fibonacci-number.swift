// Fibonacci Number
// Easy · Math, Dynamic Programming, Recursion, Memoization
// https://leetcode.com/problems/fibonacci-number
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

#Playground("Fibonacci Number") {
    class Solution {

        // Input: int
        // Output: int

        // Plan:
        // - Using recursion to find out
        // 0 1 1 2 3 5 8 13 ...
        // Give: n
        // -> n = (n-1) + (n-2)
        // -> n = (n-2+n-3) + (n-3+n-4)
        // -> n = ....

        func fib(_ n: Int) -> Int {
            if n <= 1 { return n }

            let result = fib(n - 1) + fib(n - 2)

            return result
        }
    }

    let s = Solution()
    check(s.fib(2), 1)
    check(s.fib(3), 2)
    check(s.fib(4), 3)
}

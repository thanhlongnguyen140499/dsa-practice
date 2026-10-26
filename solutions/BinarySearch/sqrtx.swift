// Sqrt(x)
// Easy · Math, Binary Search, Newton's Method
// https://leetcode.com/problems/sqrtx
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

#Playground("Sqrt(x)") {
    class Solution {

        // INput: int
        // output: int

        // Plan:
        //  - not using buil-int exponent
        //  - sqrt = n^2 = X
        //  - find out the rules of n here
        // 1 = 1 * 1    //
        // 4 = 2 * 2   // + 3
        // 9 = 3 * 3    // + 5
        // 16 = 4 * 4   // + 7
        // 25 = 5 * 5   // + 9
        // 36 = 6 * 6   // + 11
        
        // example: 8 -> (max: 4) -> return 2
        // example: 10 -> (max: 5) -> return 3
        // example 17?
        func mySqrt(_ x: Int) -> Int {
            var lo: Int = 0
            var hi: Int = x + 1
            
            while lo < hi {
                let mid = lo + (hi - lo) / 2
                
                if mid * mid <= x {
                    lo = mid + 1
                } else if mid * mid > x {
                    hi = mid
                }
            }

            return lo - 1
        }
    }

    let s = Solution()
//    check(s.mySqrt(4), 2)
    check(s.mySqrt(17), 4)
}

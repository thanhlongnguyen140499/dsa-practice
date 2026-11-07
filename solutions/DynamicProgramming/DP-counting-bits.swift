// Counting Bits
// Easy · Dynamic Programming, Bit Manipulation
// https://leetcode.com/problems/counting-bits
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

#Playground("Counting Bits") {
    class Solution {

        // MARK: Solution 1
        // Input: only a number
        // Output: an array that count how many times number 1 appears on binary
        // E.g: n = 6
        // 0    -> 0
        // 1    -> 1
        // 2    -> 10
        // 3    -> 11
        // 4    -> 100
        // 5    -> 101
        // 6    -> 110
        // => out = [0,1,1,2,1,2,2]

        // Plan:
        // - Using a loop from i: 0 -> n
        //  + Using an temp array to contains how many 1 appears in number i
        // - End: after loop n
        // Time: Big O(n)
        func countBits1(_ n: Int) -> [Int] {
            var arr: [Int] = []

            for i in 0...n {
                var tempArr = String(i, radix: 2).compactMap {
                    Int(String($0))
                }

                arr.append(tempArr.count { $0 == 1 })
            }
            return arr
        }

        func countBits(_ n: Int) -> [Int] {
            var ans = [Int](repeating: 0, count: n + 1)
            if n == 0 { return ans }
            for i in 1...n {
                ans[i] = ans[i >> 1] + (i & 1)   // reuse half, add the last bit
            }
            return ans
        }
    }

    let s = Solution()
//    check(s.countBits(2), [0, 1, 1])
    check(s.countBits(5), [0, 1, 1, 2, 1, 2])
}

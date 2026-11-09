// Single Number
// Easy · Array, Bit Manipulation
// https://leetcode.com/problems/single-number
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

#Playground("Single Number") {
    class Solution {

        // Input: Int Array - non sorted
        // Output: single number

        // MARK: Solution 1 - hash map (not meet requirement)
        // Plan:
        // - walk all nums
        //  + Using hash map to save number walked.
        func singleNumber1(_ nums: [Int]) -> Int {
            var map: [Int: Int] = [:]

            for num in nums {
                map[num, default: 0] += 1
            }
            return map.first { $0.value == 1 }!.key
        }

        // MARK: Solution 2 - XOR
        // Time: O(n)
        // Space: O(1) -> 2 ^ 2 ^ 1 = 1
        func singleNumber(_ nums: [Int]) -> Int {
            return nums.reduce(0, ^)
        }
    }

    let s = Solution()
    check(s.singleNumber([2, 2, 1]), 1)
    check(s.singleNumber([4, 1, 2, 1, 2]), 4)
    check(s.singleNumber([1]), 1)
}

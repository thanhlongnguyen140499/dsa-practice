// Happy Number
// Easy · Hash Table, Math, Two Pointers, Floyd's Cycle Finding Algorithm
// https://leetcode.com/problems/happy-number
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

#Playground("Happy Number") {
    class Solution {

        // Input: Int
        // Output: Bool

        // Plan:
        // - split numbers to an arrays contain their digits
        // - and check its digit square
        // - every new results will run check again.

        // Question:
        // - condition to skip / cancel / return value
        //      previous result = new result
        //      E.g: case -> 1000, 100, 1, 10 -> = 1

        // Hint:
        // - Hashmap -> so if new result that match with old value in hash map -> return false.

        func isHappy(_ n: Int) -> Bool {
            
            var seen: Set<Int> = []
            var current = n
            
            while current != 1 {
                if seen.contains(current) { return false }
                seen.insert(current)
                
                current = resultOfHappy(String(current).compactMap(\.wholeNumberValue))
            }
            
            
            return true
        }

        func resultOfHappy(_ nums: [Int]) -> Int {
            var result: Int = 0
            for (_, num) in nums.enumerated() {
                result = result + (num * num)
            }

            return result
        }
    }

    let s = Solution()
    check(s.isHappy(19), true)
    check(s.isHappy(2), false)
}

// Missing Number
// Easy · Array, Hash Table, Math, Binary Search, Bit Manipulation, Sorting
// https://leetcode.com/problems/missing-number
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

#Playground("Missing Number") {
    class Solution {
        // Input: [Int]
        // Output: -> missing Number (Int)
        
        // Plan:
        // - missing number in range [0,..n]
        //  + find the first missing (output is Int only)
        //  + [3, 0, 1] in [0,..2]
        //   + loop:
        //      -> 3: its not in range X
        //      -> 0: it's in range X, assign it to min
        //      -> 1: in range and bigger than min
        
        // + [9,6,4,2,3,5,7,0,1] in [0,..8]
        //  + loop:
        //      -> 9: it's not
        //      -> 6: min
        //      -> 4: min
        //      2: min
        //      3: it's not
        func missingNumber(_ nums: [Int]) -> Int {
            var result = nums.count
            
            for (i, num) in nums.enumerated() {
                result ^= i ^ num
            }
            
            return result
        }
        
        func missingNumberExplaination(_ nums: [Int]) -> Int {
            var result = 0
            
            for x in 0...nums.count {
                result ^= x
            }
            
            for num in nums {
                result ^= num
            }
            
            return result
        }
    }

    let s = Solution()
    check(s.missingNumber([3,0,1]), 2)
    check(s.missingNumber([0,1]), 2)
    check(s.missingNumber([9,6,4,2,3,5,7,0,1]), 8)
}

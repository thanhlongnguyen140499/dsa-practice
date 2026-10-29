// Two Sum
// Easy · Array, Hash Table
// https://leetcode.com/problems/two-sum
// Picked from: Google
//
// Approach:
//
// Time:  O(?)
// Space: O(?)
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Foundation
import Playgrounds

#Playground("Two Sum") {
    class Solution {

        func twoSum(_ nums: [Int], _ target: Int) -> [Int] {
            var seen: [Int: Int] = [:]
            
            for (index, num) in nums.enumerated() {
                let compliment = target - nums[index]
                
                if let j = seen[compliment] {
                    return [j, index]
                }
                
                seen[num] = index
            }
            
            return []
        }
    }

    let s = Solution()
    check(s.twoSum([2, 7, 11, 15], 9), [0, 1])
}

// [2, 7, 11, 15]
// Target = 9
//
//

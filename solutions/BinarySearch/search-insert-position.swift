// Search Insert Position
// Easy · Array, Binary Search
// https://leetcode.com/problems/search-insert-position
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

#Playground("Search Insert Position") {
    class Solution {

        // INput: [Int], target: int
        // Output: -> return index of target's index

        
        // MARK: solution 1 with O(Log(n))
        func searchInsert(_ nums: [Int], _ target: Int) -> Int {            
            var lo: Int = 0
            var hi: Int = nums.count
            
            while lo < hi {
                let mid = lo + (hi - lo) / 2
                if nums[mid] < target {
                    lo = mid + 1
                } else if nums[mid] == target {
                    return mid
                } else {
                    hi = mid
                }
            }
            
            return lo
        }
        
        // MARK: solution 2 with O(n)
        func searchInsert2(_ nums: [Int], _ target: Int) -> Int {
            var index: Int = 0

            while index < nums.count {
                if nums[index] >= target { return index }

                index += 1
            }

            return index
        }
    }

    let s = Solution()
    check(s.searchInsert([1, 2, 3, 4, 5, 6, 7], 4), 3)
    check(s.searchInsert([1, 3, 5, 6], 2), 1)
    check(s.searchInsert([1, 3, 5, 6], 7), 4)
}

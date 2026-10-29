// Merge Sorted Array
// Easy · Array, Two Pointers, Sorting
// https://leetcode.com/problems/merge-sorted-array
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

import Playgrounds

#Playground("Merge Sorted Array") {
    class Solution {
        func merge(_ nums1: inout [Int], _ m: Int, _ nums2: [Int], _ n: Int) {
            var i = m - 1
            var j = n - 1
            var k = m + n - 1
            
            // [1, 2, 3]
            // [2, 5, 6]
            
            // i = 2, j = 2, k = 5
            // [........, 6]
            
            // i = 2, j = 1, k = 4
            // [.......5, 6]
            
            // i = 2, j = 0, k = 3
            // [.....
            while j >= 0 {
                if i >= 0 && nums1[i] > nums2[j] {
                    nums1[k] = nums1[i]
                    i -= 1
                } else {
                    nums1[k] = nums2[j]
                    j -= 1
                }
                
                k -= 1
            }
        }
    }

    let s = Solution()
    var nums1 = [1,2,3,0,0,0]
    s.merge(&nums1, 3, [2,5,6], 3)
    check(nums1, [1,2,2,3,5,6])
    // Examples from LeetCode:
    // Input:  [1,2,3,0,0,0], 3, [2,5,6], 3
    // Output: [1,2,2,3,5,6]
    // Input:  [1], 1, [], 0
    // Output: [1]
    // Input:  [0], 0, [1], 1
    // Output: [1]
}

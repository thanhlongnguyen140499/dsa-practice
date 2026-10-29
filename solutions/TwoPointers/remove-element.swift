// Remove Element
// Easy · Array, Two Pointers
// https://leetcode.com/problems/remove-element
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

#Playground("Remove Element") {
    class Solution {
        
        // input: [Int]
        // output: INt
        
        // E.g: [3, 2, 2, 3],  -> k = 2
        // slow = 0, fast = 1
        // slow = 1, fast =
        // Plan:
        // - Using 2 pointers
        // - 1 pointer: write value on nums array
        // - 1 pointer: read value to compare with k
        
        // Return array of nums after changes.
        func removeElement(_ nums: inout [Int], _ val: Int) -> Int {
            guard !nums.isEmpty else { return 0 }
            var slow: Int = nums[0] != val ? 1 : 0
            
            for fast in 1..<nums.count {
                if nums[fast] != val {
                    nums[slow] = nums[fast]
                    slow += 1
                }
            }
            
            return slow
        }
    }

    let s = Solution()
    // Order of the first k cells doesn't matter → compare sorted.

    // LeetCode example 1
    var nums1 = [3, 2, 2, 3]
    let k1 = s.removeElement(&nums1, 3)
    check(k1, 2)
    check(nums1[0..<k1].sorted(), [2, 2])

    // LeetCode example 2
    var nums2 = [0, 1, 2, 2, 3, 0, 4, 2]
    let k2 = s.removeElement(&nums2, 2)
    check(k2, 5)
    check(nums2[0..<k2].sorted(), [0, 0, 1, 3, 4])

    // Empty array
    var nums3: [Int] = []
    check(s.removeElement(&nums3, 1), 0)

    // Every element equals val
    var nums4 = [5, 5, 5]
    check(s.removeElement(&nums4, 5), 0)

    // val not present → nothing removed
    var nums5 = [1, 2, 3]
    let k5 = s.removeElement(&nums5, 4)
    check(k5, 3)
    check(nums5[0..<k5].sorted(), [1, 2, 3])

    // Single element, removed
    var nums6 = [1]
    check(s.removeElement(&nums6, 1), 0)

    // Single element, kept
    var nums7 = [2]
    let k7 = s.removeElement(&nums7, 1)
    check(k7, 1)
    check(Array(nums7[0..<k7]), [2])

    // val only at the ends
    var nums8 = [4, 1, 2, 4]
    let k8 = s.removeElement(&nums8, 4)
    check(k8, 2)
    check(nums8[0..<k8].sorted(), [1, 2])
}

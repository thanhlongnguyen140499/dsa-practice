// Remove Duplicates from Sorted Array
// Easy · Array, Two Pointers
// https://leetcode.com/problems/remove-duplicates-from-sorted-array
// Picked from: —
//
// Approach: Two pointers (slow/fast). `fast` reads every element; `slow` is where the
//           next unique value gets written. Sorted → a new value differs from the last kept one.
//
// Time:  O(n)
// Space: O(1)
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("Remove Duplicates from Sorted Array") {
    class Solution {
        // Remove duplicates in place so each unique value appears once, keep the order,
        // and return k = number of unique values (first k cells hold them).
        // Plan:
        //  - nums[0] is always unique → slow = 1 (next write spot)
        //  - fast scans from 1 to the end
        //  - nums[fast] != nums[slow - 1] → new value: write it to nums[slow], slow += 1
        //  - return slow

        func removeDuplicates(_ nums: inout [Int]) -> Int {
            guard !nums.isEmpty else { return 0 }

            var slow = 1

            for fast in 1..<nums.count {
                if nums[fast] != nums[slow - 1] {
                    nums[slow] = nums[fast]
                    slow += 1
                }
            }

            return slow
        }
    }

    let s = Solution()

    var nums1 = [1, 1, 2]
    let k1 = s.removeDuplicates(&nums1)
    check(k1, 2)
    check(Array(nums1[0..<k1]), [1, 2])

    var nums2 = [0, 0, 1, 1, 1, 2, 2, 3, 3, 4]
    let k2 = s.removeDuplicates(&nums2)
    check(k2, 5)
    check(Array(nums2[0..<k2]), [0, 1, 2, 3, 4])

    var nums3 = [7]
    check(s.removeDuplicates(&nums3), 1)
}

// Merge Sorted Array
// Easy · Array, Two Pointers, Sorting
// https://leetcode.com/problems/merge-sorted-array
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

#Playground("Merge Sorted Array") {
    class Solution {
        // Input: 2 arrays + 2 length
        // Output: none, -> just need to modify nums1

        // [1,2,3,0,0,0] + m = 3 vs [2,5,6] + n = 3
        // Expected: nums1 = [1, 2, 2, 3, 5, 6]

        // Plan:
        // - new nums1 length = m + n = 6
        // - walk from 0 -> 6
        // - Using two pointer to track:
        //  + pointer 1 - i: -> [1, 2, 3]
        //  + pointer 2 - j: -> [2, 5, 6]

        // - Compare nums1[i] vs nums2[j]
        //  => nums1[index] = nums1[i] || nums [j]

        func merge(_ nums1: inout [Int], _ m: Int, _ nums2: [Int], _ n: Int) {
            var i = m - 1
            var j = n - 1
            var write = m + n - 1

            while j >= 0 {
                if i >= 0 && nums1[i] > nums2[j] {
                    nums1[write] = nums1[i]
                    i -= 1
                } else {
                    nums1[write] = nums2[j]
                    j -= 1
                }

                write -= 1
            }
        }
    }

    let s = Solution()
    // nums1 is inout, so run merge on a copy and return the result
    func run(_ nums1: [Int], _ m: Int, _ nums2: [Int], _ n: Int) -> [Int] {
        var nums1 = nums1
        s.merge(&nums1, m, nums2, n)
        return nums1
    }

    // Examples from LeetCode
    check(run([1, 2, 3, 0, 0, 0], 3, [2, 5, 6], 3), [1, 2, 2, 3, 5, 6])
    check(run([1], 1, [], 0), [1])
    check(run([0], 0, [1], 1), [1])

    // nums2 all smaller → everything shifts right
    check(run([4, 5, 6, 0, 0, 0], 3, [1, 2, 3], 3), [1, 2, 3, 4, 5, 6])
    // nums2 all bigger → just append
    check(run([1, 2, 3, 0, 0, 0], 3, [4, 5, 6], 3), [1, 2, 3, 4, 5, 6])
    // interleaved
    check(run([1, 3, 5, 0, 0, 0], 3, [2, 4, 6], 3), [1, 2, 3, 4, 5, 6])
    // duplicates across both arrays
    check(run([2, 2, 3, 0, 0], 3, [2, 2], 2), [2, 2, 2, 2, 3])
    // negatives
    check(run([-3, 0, 5, 0, 0], 3, [-5, 1], 2), [-5, -3, 0, 1, 5])
    // different sizes: m > n
    check(run([1, 2, 7, 8, 0], 4, [3], 1), [1, 2, 3, 7, 8])
    // different sizes: m < n
    check(run([5, 0, 0, 0, 0], 1, [1, 2, 6, 9], 4), [1, 2, 5, 6, 9])
    // nums1's real part has a 0 that is NOT a placeholder
    check(run([0, 0, 3, 0, 0, 0], 3, [-1, 1, 2], 3), [-1, 0, 0, 1, 2, 3])
    // all equal
    check(run([1, 1, 0, 0], 2, [1, 1], 2), [1, 1, 1, 1])
}

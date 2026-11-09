// Container With Most Water
// Medium · Array, Two Pointers, Greedy
// https://leetcode.com/problems/container-with-most-water
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

#Playground("Container With Most Water") {
    class Solution {
        // Input: int array
        // Output: number

        // Analytics:
        //         [1,8,6,2,5,4,8,3,7]
        // x-axis:  1 2 3           9

        // MARK: Solution 1
        // Time: Big O(n2)
        // Space: Big O(1)
        // Plan:
        // - Walk through all value
        //  -> calculate square
        //  -> save max value
        func maxArea1(_ height: [Int]) -> Int {
            var maxValue: Int = Int.min

            for i in 0..<height.count - 1 {
                for j in i..<height.count {
                    let area = (j - i) * min(height[i], height[j])
                    maxValue = max(maxValue, area)
                }
            }

            return maxValue
        }

        // MARK: Solution 2
        // Plan:
        // - Using 2 pointers
        // Time: O(n), Space: O(1)
        func maxArea(_ height: [Int]) -> Int {
            var left: Int = 0
            var right: Int = height.count - 1
            var result: Int = Int.min

            while left < right {
                let area =
                    (right - left)
                    * min(height[left], height[right])

                result = max(result, area)

                height[left] < height[right] ? (left += 1) : (right -= 1)
            }

            return result
        }
    }

    let s = Solution()
    check(s.maxArea([1, 8, 6, 2, 5, 4, 8, 3, 7]), 49)
    check(s.maxArea([1, 1]), 1)
}

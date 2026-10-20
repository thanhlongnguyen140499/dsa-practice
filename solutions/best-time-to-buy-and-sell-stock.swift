// Best Time to Buy and Sell Stock
// Easy · Array, Dynamic Programming
// https://leetcode.com/problems/best-time-to-buy-and-sell-stock
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

#Playground("Best Time to Buy and Sell Stock") {
    class Solution {
        func maxProfit(_ prices: [Int]) -> Int {
            return 0
        }
    }

    let s = Solution()
    check(s.maxProfit([7,1,5,3,6,4]), 5)
    check(s.maxProfit([7,6,4,3,1]), 0)
}

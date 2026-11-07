// Best Time to Buy and Sell Stock
// Easy · Array, Dynamic Programming
// https://leetcode.com/problems/best-time-to-buy-and-sell-stock
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

#Playground("Best Time to Buy and Sell Stock") {
    class Solution {
        // Input: An Integer Array
        // Output: A Number

        // Plan:
        // - we assign min value
        //  + Rely on min value then we can find max profit

        func maxProfit(_ prices: [Int]) -> Int {
            var minPrice: Int = prices[0]
            var maxProfit: Int = 0

            for price in prices {
                minPrice = min(minPrice, price)
                maxProfit = max(maxProfit, price - minPrice)
            }

            return maxProfit
        }
    }

    let s = Solution()
    check(s.maxProfit([7, 1, 5, 3, 6, 4]), 5)
    check(s.maxProfit([7, 6, 4, 3, 1]), 0)
}

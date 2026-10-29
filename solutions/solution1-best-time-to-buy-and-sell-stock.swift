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
        // MARK: Solution 2
        // E.g: [7, 1, 5, 3, 6, 4]
        func maxProfit(_ prices: [Int]) -> Int {
            var minPrice = Int.max
            var maxPrice = 0
            
            for price in prices {
                if price < minPrice {
                    minPrice = price
                } else {
                    maxPrice = max(maxPrice, price - minPrice)
                }
            }
            
            return maxPrice
        }
        
        // MARK: Solution 1 with BigO(n^2)
        func maxProfit2(_ prices: [Int]) -> Int {
            // Each item:
                // -> check profit with others
                // -> Find: the higest profit
                // -> save to hash map
                // -> Compare with others
            
            var highestProfit: Int = 0
            
            for i in 0..<prices.count - 1 {
                for j in i+1..<prices.count {
                    if prices[i] < prices[i + 1] {
                        let profit = prices[j] - prices[i]
                        if profit > highestProfit {
                            highestProfit = profit
                        }
                    }
                }
            }
            
            return highestProfit
        }
    }

    let s = Solution()
    check(s.maxProfit([7,1,5,3,6,4]), 5)
    check(s.maxProfit([7,6,4,3,1]), 0)
}

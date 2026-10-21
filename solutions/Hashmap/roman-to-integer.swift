// Roman to Integer
// Easy · Hash Table, Math, String
// https://leetcode.com/problems/roman-to-integer
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

#Playground("Roman to Integer") {
    class Solution {
        func romanToInt(_ s: String) -> Int {
            /**
             Plan:
             - save all symbol + value into hash map
             - read symbol from left to right to analyc
             */

            let map: [Character: Int] = [
                "I": 1,
                "V": 5,
                "X": 10,
                "L": 50,
                "C": 100,
                "D": 500,
                "M": 1000,
            ]
            let chars: [Character] = Array(s)
            var result: Int = 0

            // E.g: chars = "VIII"
            for i in 0..<chars.count {
                let value = map[chars[i]] ?? 0
                let nextValue =
                    i + 1 < chars.count ? (map[chars[i + 1]] ?? 0) : 0

                if value < nextValue {
                    result -= value
                } else {
                    result += value
                }
            }

            return result
        }
    }

    let s = Solution()
    check(s.romanToInt("III"), 3)
    //    check(s.romanToInt("LVIII"), 58)
    //    check(s.romanToInt("MCMXCIV"), 1994)
}

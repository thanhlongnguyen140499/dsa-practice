// Integer to Roman
// Medium · Hash Table, Math, String
// https://leetcode.com/problems/integer-to-roman
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

#Playground("Integer to Roman") {
    class Solution {
        func intToRoman(_ num: Int) -> String {
            let table: [Int: String] = [
                1000: "M", 900: "CM", 500: "D", 400: "CD",
                100: "C", 90: "XC", 50: "L", 40: "XL",
                10: "X", 9: "IX", 5: "V", 4: "IV", 1: "I",
            ]
            var numValue = num
            var result = ""

            for value in table.keys.sorted(by: >) {
                while numValue >= value {
                    result += table[value]!
                    numValue -= value
                }
            }
            
            return result
        }
    }

    let s = Solution()
    check(s.intToRoman(3749), "MMMDCCXLIX")
    check(s.intToRoman(58), "LVIII")
    check(s.intToRoman(1994), "MCMXCIV")
}

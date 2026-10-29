// Palindrome Number
// Easy · Math
// https://leetcode.com/problems/palindrome-number
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

#Playground("Palindrome Number") {
    class Solution {
        func isPalindrome(_ x: Int) -> Bool {            
            // 0 -> 0 -> ends: 0
            // 12 -> 2 -> ends: 1
            // 123 -> 3 -> ends: 1
            // 1234 -> 4 -> ends: 2
            // 12345 -> 5 -> ends: 2
            
            if x < 0 { return false }
            
            let digits = Array(String(x))
            let count = digits.count
            
            for i in 0..<count / 2 {
                if digits[i] != digits[count - 1 - i] {
                    return false
                }
            }
            
            return true
        }
    }

    let s = Solution()
//    check(s.isPalindrome(121), true)
    check(s.isPalindrome(-121), false)
//    check(s.isPalindrome(10), false)
}

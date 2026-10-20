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
            return false
        }
    }

    let s = Solution()
    check(s.isPalindrome(121), true)
    check(s.isPalindrome(-121), false)
    check(s.isPalindrome(10), false)
}

// Valid Palindrome
// Easy · Two Pointers, String
// https://leetcode.com/problems/valid-palindrome
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

#Playground("Valid Palindrome") {
    class Solution {

        // Input: String
        // Output: Bool

        // Plan:
        // - Using 2 pointers to track start and end
        // - compare until:
        //  + 2 pointers reach to the middle
        //  + when mismatch between 2 pointers

        func isPalindrome(_ s: String) -> Bool {
            let s: [Character] = s.lowercased().filter {
                $0.isLetter || $0.isNumber
            }
            var start: Int = 0
            var end: Int = s.count - 1

            while start < end {
                if s[start] == s[end] {
                    start += 1
                    end -= 1
                } else {
                    return false
                }
            }

            return true
        }
    }

    let s = Solution()
    check(s.isPalindrome("A man, a plan, a canal: Panama"), true)
    check(s.isPalindrome("race a car"), false)
    check(s.isPalindrome(" "), true)
}

// Longest Common Prefix
// Easy · Array, String, Trie
// https://leetcode.com/problems/longest-common-prefix
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

#Playground("Longest Common Prefix") {
    class Solution {
        func longestCommonPrefix(_ strs: [String]) -> String {
            return ""
        }
    }

    let s = Solution()
    check(s.longestCommonPrefix(["flower","flow","flight"]), "fl")
    check(s.longestCommonPrefix(["dog","racecar","car"]), "")
}

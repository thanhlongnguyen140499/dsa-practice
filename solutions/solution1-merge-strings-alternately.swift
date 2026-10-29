// Merge Strings Alternately
// Easy · Two Pointers, String
// https://leetcode.com/problems/merge-strings-alternately
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

#Playground("Merge Strings Alternately") {
    class Solution {
        func mergeAlternately(_ word1: String, _ word2: String) -> String {
            let a = Array(word1)
            let b = Array(word2)
            var result: [Character] = []

            for i in 0..<max(a.count, b.count) {
                if i < a.count { result.append(a[i]) }
                if i < b.count { result.append(b[i]) }
            }
            return String(result)
        }
    }

    let s = Solution()
//    check(s.mergeAlternately("abc", "pqr"), "apbqcr")
        check(s.mergeAlternately("ab", "pqrs"), "apbqrs")
    //    check(s.mergeAlternately("abcd", "pq"), "apbqcd")
}

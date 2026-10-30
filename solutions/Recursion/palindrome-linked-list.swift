// Palindrome Linked List
// Easy · Linked List, Two Pointers, Stack, Recursion
// https://leetcode.com/problems/palindrome-linked-list
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

#Playground("Palindrome Linked List") {
    class Solution {
        var front: ListNode?

        func isPalindrome(_ head: ListNode?) -> Bool {
            front = head
            return matches(head)
        }

        private func matches(_ node: ListNode?) -> Bool {
            guard let node = node else { return true }
            if !matches(node.next) { return false }
            if front?.val != node.val { return false }
            front = front?.next
            return true
        }
    }

    let s = Solution()
    check(s.isPalindrome(list([1,2,2,1])), true)
    check(s.isPalindrome(list([1,2])), false)
}

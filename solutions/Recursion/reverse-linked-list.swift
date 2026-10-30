// Reverse Linked List
// Easy · Linked List, Recursion
// https://leetcode.com/problems/reverse-linked-list
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

#Playground("Reverse Linked List") {
    class Solution {
        func reverseList(_ head: ListNode?) -> ListNode? {
            guard let head = head, let next = head.next else { return head }
            
            let newHead = reverseList(next)
            head.next?.next = head
            head.next = nil
            
            return newHead
        }
    }

    let s = Solution()
    check(array(of: s.reverseList(list([1, 2, 3, 4, 5]))), [5, 4, 3, 2, 1])
        check(array(of: s.reverseList(list([1,2]))), [2,1])
        check(array(of: s.reverseList(list([]))), [])
}

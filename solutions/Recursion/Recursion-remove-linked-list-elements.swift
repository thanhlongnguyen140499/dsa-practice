// Remove Linked List Elements
// Easy · Linked List, Recursion
// https://leetcode.com/problems/remove-linked-list-elements
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

#Playground("Remove Linked List Elements") {
    class Solution {
        func removeElements(_ head: ListNode?, _ val: Int) -> ListNode? {

            guard let head else { return nil }
            
            head.next = removeElements(head.next, val)
            return head.val == val ? head.next : head
        }
    }

    let s = Solution()
    check(
        array(of: s.removeElements(list([1, 2, 6, 3, 4, 5, 6]), 6)),
        [1, 2, 3, 4, 5]
    )
    //    check(array(of: s.removeElements(list([]), 1)), [])
    //    check(array(of: s.removeElements(list([7,7,7,7]), 7)), [])
}

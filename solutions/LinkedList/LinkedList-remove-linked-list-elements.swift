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
        // Input: ListNode
        // Output: ListNode
        
        // Expected: remove ALL nodes with value = ...
        // Plan:
        // - walked all node to remove
        
        func removeElements(_ head: ListNode?, _ val: Int) -> ListNode? {
            
            let dummy = ListNode(0)
            dummy.next = head
            var current = dummy
            
            while let next = current.next {
                if next.val == val {
                    current.next = next.next
                } else {
                    current = next
                }
            }
            
            return dummy.next
        }
    }

    let s = Solution()
    check(array(of: s.removeElements(list([1,2,6,3,4,5,6]), 6)), [1,2,3,4,5])
    check(array(of: s.removeElements(list([]), 1)), [])
    check(array(of: s.removeElements(list([7,7,7,7]), 7)), [])
}

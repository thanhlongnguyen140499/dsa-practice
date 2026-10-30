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
        
        // Input: ListNode
        // Output: ListNode
        
        // Plan
        // - Using recursion to recall
        //
        //         3
        //           1
        //              4
        //                  5

        // - I gonna use a new ListNode to return
        // - walk to end of current list node
        func reverseList(_ head: ListNode?) -> ListNode? {
            
            var newList = ListNode()
            
            if let head = head {
                
                let next = reverseList(head.next)
                
                newList.next = head
                newList.next?.next = next
            }
            return newList
        }
    }

    let s = Solution()
    check(array(of: s.reverseList(list([1,2,3,4,5]))), [5,4,3,2,1])
//    check(array(of: s.reverseList(list([1,2]))), [2,1])
//    check(array(of: s.reverseList(list([]))), [])
}

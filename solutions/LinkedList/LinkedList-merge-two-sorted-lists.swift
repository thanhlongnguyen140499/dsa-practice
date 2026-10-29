// Merge Two Sorted Lists
// Easy · Linked List, Recursion
// https://leetcode.com/problems/merge-two-sorted-lists
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

#Playground("Merge Two Sorted Lists") {
    class Solution {
        func mergeTwoLists(_ list1: ListNode?, _ list2: ListNode?) -> ListNode?
        {

            // Input: 2 list node
            // Output: 1 list node

            // Plan:
            // -> return a new list Node that combine both list1 & list2
            // - Maybe: create a new list node
            // - use WHile to loop all items in both list nodes

            // Ended:
            // -> no contains next in each loops

            let dummy = ListNode()
            var tail = dummy
            var l1 = list1
            var l2 = list2
            
            while let a = l1, let b = l2 {
                if a.val <= b.val {
                    tail.next = a
                    l1 = a.next
                } else {
                    tail.next = b
                    l2 = b.next
                }
                
                tail = tail.next!
            }
            
            tail.next = l1 ?? l2
            return dummy.next
        }
    }

    let s = Solution()
    check(
        array(of: s.mergeTwoLists(list([1, 2, 4]), list([1, 3, 4]))),
        [1, 1, 2, 3, 4, 4]
    )
    //    check(array(of: s.mergeTwoLists(list([]), list([]))), [])
    //    check(array(of: s.mergeTwoLists(list([]), list([0]))), [0])
}

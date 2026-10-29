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
        // Input: 2 ListNode
        // Output: sorted ListNode

        // Plan:
        // - Using recursion
        //  + Compare between current value of each node
        //  + Found node -> use recursion for node.next
        func mergeTwoLists(_ list1: ListNode?, _ list2: ListNode?) -> ListNode?
        {
            guard var l1 = list1 else { return list2 }
            guard var l2 = list2 else { return list1 }

            if l1.val <= l2.val {
                l1.next = mergeTwoLists(l1.next, l2)

                return l1
            } else {
                l2.next = mergeTwoLists(l2.next, l1)

                return l2
            }
        }
    }

    let s = Solution()
    check(
        array(of: s.mergeTwoLists(list([1, 2, 4]), list([1, 3, 4]))),
        [1, 1, 2, 3, 4, 4]
    )
    check(array(of: s.mergeTwoLists(list([]), list([]))), [])
    check(array(of: s.mergeTwoLists(list([]), list([0]))), [0])
}

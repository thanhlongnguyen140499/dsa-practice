// Add Two Numbers
// Medium · Linked List, Math, Recursion
// https://leetcode.com/problems/add-two-numbers
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

#Playground("Add Two Numbers") {
    class Solution {
        //  [2, 4, 3]
        //  [5, 6, 4]
        func addTwoNumbers(_ l1: ListNode?, _ l2: ListNode?) -> ListNode {

            var dummy = ListNode(0)
            var tail = dummy
            var sum: Int = 0
            var p1 = l1
            var p2 = l2
            var carry: Int = 0

            while p1 != nil || p2 != nil || carry > 0 {
                sum = (p1?.val ?? 0) + (p2?.val ?? 0) + carry
                carry = sum / 10

                tail.next = ListNode(sum % 10)  // {val: 7, next}
                tail = tail.next!

                p1 = p1?.next
                p2 = p2?.next
            }

            return dummy.next!
        }
    }

    let s = Solution()
    check(
        array(of: s.addTwoNumbers(list([2, 4, 3]), list([5, 6, 4]))),
        [7, 0, 8]
    )
    check(
        array(of: s.addTwoNumbers(list([2, 4, 3]), list([5, 6, 4]))),
        [7, 0, 8]
    )
    check(array(of: s.addTwoNumbers(list([0]), list([0]))), [0])
    check(
        array(
            of: s.addTwoNumbers(
                list([9, 9, 9, 9, 9, 9, 9]),
                list([9, 9, 9, 9])
            )
        ),
        [8, 9, 9, 9, 0, 0, 0, 1]
    )
}

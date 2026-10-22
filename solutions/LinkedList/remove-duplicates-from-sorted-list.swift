// Remove Duplicates from Sorted List
// Easy · Linked List
// https://leetcode.com/problems/remove-duplicates-from-sorted-list
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

#Playground("Remove Duplicates from Sorted List") {
    class Solution {
        // E.g: [1, 1, 2]

        // Input: list node ?
        // Output: list node ?
        // Plan:
        // - Using loop from left to right
        // - compare current value to next value
        //      + if both are equal -> skip next
        //      + If not -> next loop

        // Return:
        // - End of loop
        func deleteDuplicates(_ head: ListNode?) -> ListNode? {
            var current = head

            while let node = current, let next = node.next {
                if node.val == next.val {
                    node.next = next.next
                } else {
                    current = next
                }
            }

            return current
        }
    }

    let s = Solution()
    check(array(of: s.deleteDuplicates(list([1, 1, 2]))), [1, 2])
    check(array(of: s.deleteDuplicates(list([1, 1, 2, 3, 3]))), [1, 2, 3])
}

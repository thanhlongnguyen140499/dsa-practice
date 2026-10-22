// Linked List Cycle
// Easy · Hash Table, Linked List, Two Pointers, Floyd's Cycle Finding Algorithm
// https://leetcode.com/problems/linked-list-cycle
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

#Playground("Linked List Cycle") {
    class Solution {
        func hasCycle(_ head: ListNode?) -> Bool {
            // Input: linked node
            // Output: true/false

            // Plan:
            //  - Hashmap to store value that loops through already
            //  - check if same value then shows that it's a circle

            // Result:
            // - have a circle

            var currentNode: ListNode? = head
            var seen: Set<ObjectIdentifier> = []

            while let node = currentNode {
                if seen.contains(ObjectIdentifier(node)) { return true }
                
                seen.insert(ObjectIdentifier(node))
                currentNode = currentNode?.next
            }

            return false
        }
    }

    let s = Solution()
    check(s.hasCycle(list([3, 2, 0, -4], cycleAt: 1)), true)
    check(s.hasCycle(list([1, 2], cycleAt: 0)), true)
    check(s.hasCycle(list([1], cycleAt: -1)), false)
    check(s.hasCycle(list([1, 1, 2], cycleAt: -1)), false)
}

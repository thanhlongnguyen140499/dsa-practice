// Intersection of Two Linked Lists
// Easy · Hash Table, Linked List, Two Pointers
// https://leetcode.com/problems/intersection-of-two-linked-lists
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

#Playground("Intersection of Two Linked Lists") {
    class Solution {
        // input: list node
        // output: list node
        
        // Note:
        // same value but in skip then still not a intersected node
        
        // Plan:
        // Approach: Two pointers. p walks A then B, q walks B then A. Both cover
        //           a + b + c steps, so they reach the intersection together
        //           (or both reach nil if there's none).
        // Time:  O(m + n)
        // Space: O(1)

        func getIntersectionNode(_ headA: ListNode?, _ headB: ListNode?)
            -> ListNode?
        {
            var seen = Set<ObjectIdentifier>()
            
            var p = headA
            while let node = p {
                seen.insert(ObjectIdentifier(node))
                p = node.next
            }
            
            var q = headB
            while let node = q {
                if seen.contains(ObjectIdentifier(node)) {
                    return node
                }
                q = node.next
            }
            
            return nil
        }
    }

    let s = Solution()

    // Example 1: Intersected at '8'
    let (a1, b1) = intersecting(
        [4, 1, 8, 4, 5],
        [5, 6, 1, 8, 4, 5],
        skipA: 2,
        skipB: 3
    )
    print("A:", array(of: a1), " B:", array(of: b1))  // A: [4, 1, 8, 4, 5]  B: [5, 6, 1, 8, 4, 5]
    let got1 = s.getIntersectionNode(a1, b1)
    check(got1?.val, 8)
    check(got1 === a1?.next?.next, true)  // same node object, not just same value

    // Example 2: Intersected at '2'
    //    let (a2, b2) = intersecting([1, 9, 1, 2, 4], [3, 2, 4], skipA: 3, skipB: 1)
    //    print("A:", array(of: a2), " B:", array(of: b2))
    //    let got2 = s.getIntersectionNode(a2, b2)
    //    check(got2?.val, 2)
    //    check(got2 === b2?.next, true)

    // Example 3: No intersection
    //    let (a3, b3) = intersecting([2, 6, 4], [1, 5], skipA: 3, skipB: 2)
    //    print("A:", array(of: a3), " B:", array(of: b3))
    //    check(s.getIntersectionNode(a3, b3)?.val, nil)I
}

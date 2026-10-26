// Time Needed to Buy Tickets
// Easy · Array, Queue, Simulation
// https://leetcode.com/problems/time-needed-to-buy-tickets
// Picked from: —
//
// Approach: Queue of indices (not values), so person k keeps their identity
//           while the line rotates. Each second: pop the front person, they
//           buy one ticket. If that was k's last ticket, stop. If they still
//           need more, push them to the back; otherwise they leave.

// Time:  O(n * tickets[k]) (each round costs at most n seconds)
// Space: O(n)
//
// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("Time Needed to Buy Tickets") {
    class Solution {
        // E.g: [5, 1, 1, 1], k = 0

        // Input: tickets [Int] + k = Int (Amber)
        // Plan:
        // - Queue to track number of each ticket
        //      - index: check < 1 -> remove out of queue
        //      - track: only amber until it reach 0

        // Questions:
        // - How to track k index after changing queue
        //      idea: remove, or change, have to change k
        //      [5, 1, 1, 1] -> k = 0
        //      [1, 1, 1, 4] -> k = 3
        //      [1, 1, 3]   -> k = 2
        //

        // [2, 3, 2] -> k = 2
        // [3, 2, 1] -> k = 1
        // [2, 1, 2] -> k = 0
        // [1, 2, 1] -> k = 2
        // Answer to "how to track k": store indices in the queue, so k never moves.
        func timeRequiredToBuy(_ tickets: [Int], _ k: Int) -> Int {
            var time: Int = 0
            var remaining: [Int] = tickets
            var queue: [Int] = Array(tickets.indices)
            var head: Int = 0

            while head < queue.count {
                let person = queue[head]
                head += 1

                remaining[person] -= 1
                time += 1

                if k == person && remaining[person] < 1 {
                    return time
                }

                if remaining[person] > 0 {
                    queue.append(person)
                }
            }

            return time
        }
    }

    let s = Solution()
    check(s.timeRequiredToBuy([2, 3, 2], 2), 6)
    check(s.timeRequiredToBuy([5, 1, 1, 1], 0), 8)
}

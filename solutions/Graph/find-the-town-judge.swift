// Find the Town Judge
// Easy · Array, Hash Table, Graph Theory
// https://leetcode.com/problems/find-the-town-judge
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

#Playground("Find the Town Judge") {
    class Solution {
        // Input
        func findJudge(_ n: Int, _ trust: [[Int]]) -> Int {
            var score = [Int](repeating: 0, count: n + 1)

            for t in trust {
                score[t[0]] -= 1
                score[t[1]] += 1
            }
            for p in 1...n where score[p] == n - 1 {
                return p
            }

            return 0
        }
    }

    let s = Solution()
    check(s.findJudge(2, [[1, 2]]), 2)
    //    check(s.findJudge(3, [[1,3],[2,3]]), 3)
    //    check(s.findJudge(3, [[1,3],[2,3],[3,1]]), -1)
}

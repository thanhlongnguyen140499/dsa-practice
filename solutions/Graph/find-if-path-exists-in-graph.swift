// Find if Path Exists in Graph
// Easy · Depth-First Search, Breadth-First Search, Union-Find, Graph Theory
// https://leetcode.com/problems/find-if-path-exists-in-graph
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

#Playground("Find if Path Exists in Graph") {
    class Solution {
        func validPath(
            _ n: Int,
            _ edges: [[Int]],
            _ source: Int,
            _ destination: Int
        ) -> Bool {
            var adj = [[Int]](repeating: [], count: n)

            for e in edges {
                adj[e[0]].append(e[1])
                adj[e[1]].append(e[0])
            }

            var visited = [Bool](repeating: false, count: n)
            var queue = [source]
            visited[source] = true
            var head = 0

            while head < queue.count {
                let u = queue[head]
                head += 1
                for v in adj[u] where !visited[v] {
                    if v == destination { return true }
                    visited[v] = true
                    queue.append(v)
                }
            }
            return false
        }
    }

    let s = Solution()
    check(s.validPath(3, [[0, 1], [1, 2], [2, 0]], 0, 2), true)
    //    check(s.validPath(6, [[0,1],[0,2],[3,5],[5,4],[4,3]], 0, 5), false)
}

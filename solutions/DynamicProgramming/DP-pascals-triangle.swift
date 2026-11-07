// Pascal's Triangle
// Easy · Array, Dynamic Programming
// https://leetcode.com/problems/pascals-triangle
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

#Playground("Pascal's Triangle") {
    class Solution {
        // Input: Int
        // Output: 2D Array
        //        Array = [[1],[1,1],[1,2,1],[1,3,3,1]
        //
        //        n = 5
        //        A[0] = [1]
        //        A[1] = [1, 1]
        //        A[2] = [1, 2, 1]
        //        A[3] = [1, 3, 3, 1]
        //        A[4] = [1, 4, 6, 4, 1]
        //
        //        --- Default
        //        A[0] = [1]
        //        A[n][0] = 1
        //        A[n][n] = 1

        // Time + Space: Big O(n^2)
        func generate(_ numRows: Int) -> [[Int]] {
            if numRows == 1 { return [[1]] }
            if numRows == 2 { return [[1], [1, 1]] }

            var A: [[Int]] = []

            for i in 0..<numRows {
                var row = [Int](repeating: 1, count: i + 1)
                if i >= 2 {
                    for j in 1..<i {
                        row[j] = A[i - 1][j - 1] + A[i - 1][j]
                    }
                }

                A.append(row)
            }

            return A
        }
    }

    let s = Solution()
    check(
        s.generate(5),
        [[1], [1, 1], [1, 2, 1], [1, 3, 3, 1], [1, 4, 6, 4, 1]]
    )
    check(s.generate(1), [[1]])
}

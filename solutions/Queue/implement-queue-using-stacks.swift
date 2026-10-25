// Implement Queue using Stacks
// Easy · Stack, Design, Queue
// https://leetcode.com/problems/implement-queue-using-stacks
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

#Playground("Implement Queue using Stacks") {

    class MyQueue {
        private var inStack: [Int] = []
        private var outStack: [Int] = []

        init() {}

        func push(_ x: Int) {
            inStack.append(x)
        }

        func pop() -> Int {
            moveIfNeeded()
            return outStack.popLast()!
        }

        func peek() -> Int {
            moveIfNeeded()
            return outStack.last!
        }

        func empty() -> Bool {
            return inStack.isEmpty && outStack.isEmpty
        }
        
        // Reverse inStack into outStack only when outStack runs dry.
        private func moveIfNeeded() {
            if outStack.isEmpty {
                while let x = inStack.popLast() {
                    outStack.append(x)
                }
            }
        }
    }

    /**
     * Your MyQueue object will be instantiated and called as such:
     * let obj = MyQueue()
     * obj.push(x)
     * let ret_2: Int = obj.pop()
     * let ret_3: Int = obj.peek()
     * let ret_4: Bool = obj.empty()
     */

    // Examples from LeetCode:
}

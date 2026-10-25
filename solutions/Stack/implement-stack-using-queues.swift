// Implement Stack using Queues
// Easy · Stack, Design, Queue
// https://leetcode.com/problems/implement-stack-using-queues
// Picked from: —

// Approach: One queue. After each push, rotate the older count-1 elements
//           to the back so the newest element sits at the front. Then pop/top
//           are plain front-of-queue operations.

// Time:  push O(n), pop/top/empty O(1)
// Space: O(n)

// Results show in Xcode's canvas (Editor → Canvas, ⌥⌘↩).
// Submit only `class Solution { ... }` to LeetCode.
// Helpers: check(got, want), list([1,2]), array(of:), tree([1,nil,2]), levelOrder(of:)

import Playgrounds

#Playground("Implement Stack using Queues") {

    class MyStack {
        // Only queue operations: append (push back), removeFirst (pop front),
        // first (peek front), isEmpty, count.
        private var queue: [Int] = []

        init() {}

        func push(_ x: Int) {
            queue.append(x)
            // Rotate the older elements behind x so x ends up at the front.
            // E.g. [2, 1] + push 3 -> [2, 1, 3] -> [1, 3, 2] -> [3, 2, 1]
            for _ in 0..<queue.count - 1 {
                queue.append(queue.removeFirst())
            }
        }

        func pop() -> Int {
            return queue.removeFirst()
        }

        func top() -> Int {
            return queue.first!
        }

        func empty() -> Bool {
            return queue.isEmpty
        }
    }

    /**
     * Your MyStack object will be instantiated and called as such:
     * let obj = MyStack()
     * obj.push(x)
     * let ret_2: Int = obj.pop()
     * let ret_3: Int = obj.top()
     * let ret_4: Bool = obj.empty()
     */

    // Examples from LeetCode:
    // ["MyStack","push","push","top","pop","empty"]
    // [[],[1],[2],[],[],[]] -> [null,null,null,2,2,false]
    let s1 = MyStack()
    s1.push(1)
    s1.push(2)
    check(s1.top(), 2)
    check(s1.pop(), 2)
    check(s1.empty(), false)

    // Fresh stack is empty
    let s2 = MyStack()
    check(s2.empty(), true)

    // Single element: push then pop back to empty
    let s3 = MyStack()
    s3.push(5)
    check(s3.top(), 5)
    check(s3.empty(), false)
    check(s3.pop(), 5)
    check(s3.empty(), true)

    // LIFO order across many pushes; top() doesn't remove
    let s4 = MyStack()
    s4.push(1)
    s4.push(2)
    s4.push(3)
    check(s4.top(), 3)
    check(s4.top(), 3)
    check(s4.pop(), 3)
    check(s4.pop(), 2)
    check(s4.pop(), 1)
    check(s4.empty(), true)

    // Interleaved push/pop
    let s5 = MyStack()
    s5.push(1)
    s5.push(2)
    check(s5.pop(), 2)
    s5.push(3)
    check(s5.top(), 3)
    check(s5.pop(), 3)
    check(s5.pop(), 1)
    check(s5.empty(), true)

    // Duplicates and boundary values (1 <= x <= 9)
    let s6 = MyStack()
    s6.push(9)
    s6.push(9)
    s6.push(1)
    check(s6.pop(), 1)
    check(s6.pop(), 9)
    check(s6.top(), 9)
    check(s6.empty(), false)
}

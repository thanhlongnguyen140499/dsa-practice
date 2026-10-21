import Foundation
import Playgrounds

#Playground("Two Sum") {
    class Solution {

        func twoSumV2(_ nums: [Int], _ target: Int) -> [Int] {
            print("hello")
            
            // use Hashmap
            
            var seen: [Int: Int] = [:]
            
            for (i, num) in nums.enumerated() {
                let complement: Int = target - num
                
                if (seen[complement] != nil) {
                    return [seen[complement]!, i]
                }
                
                seen[num] = i
            }
            
            return []
        }
    }

    let s = Solution()
    check(s.twoSumV2([2, 7, 11, 15], 9), [0, 1])
}

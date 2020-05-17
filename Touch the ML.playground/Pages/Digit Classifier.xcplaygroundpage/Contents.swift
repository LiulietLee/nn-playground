/*:
 # Touch the ML
 
 On WWDC 19, I attended a session about Machine Learning, which led me to the world of Computer Vision.
 
 From that time I began to search related learning materials on the Internet to teach myself. And finally, I finished a tiny CNN framework by using Swift and Metal, for both iOS and macOS, from scratch.
 
 I used my framework to train a handwritten digit classifier and here is the work.
 */

import PlaygroundSupport

PlaygroundPage.current.liveView = PredViewController()

/*:
- Experiment:
 Classify a handwritten digit.
 
    1. Use your mouse to write a digit on the blackboard of the live view.
    2. The playground will classify your digit automatically. I wrote metal code to do computation on **GPU** but not Swift on **CPU**, so we can get the result immediately.
*/

/*:
 I also wrote a visual playground for those who don't familiar with neural networks to give them a touch about machine learning. It will be shown in the remaining pages.
 */

//: [Next: Linear classification](@next)

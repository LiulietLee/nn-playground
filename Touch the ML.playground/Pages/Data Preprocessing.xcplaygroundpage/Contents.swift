//: [Previous: Multilayer Network](@previous)

/*:
 ## Data Preprocessing
 
 ### Why do we need to preprocess data?
 
 Sometimes we can get good performance with a simple network structure by processing the raw input data before feeding it to the network.
 
 For example, in this dataset, we have red dots at the center and white dots outlying.
 
 We need at least a 2-layer network to restrict the red area to the center.
    
 But if we can do a data preprocessing, we can use linear classification to solve this problem.
 */

import SwiftUI
import PlaygroundSupport
//: - Note: If the size of the live view is too large for your screen, you can adjust the `scale` variable to `0.8` and run again.
let scale: CGFloat = 1.0

PlaygroundPage.current.liveView = DataPreprocessingView(scale)

/*:
 - Experiment:
 Use a multilayer network to solve this problem.

    You can tap the play button directly, or adjust the network before training.
 */

/*:
 ### How to preprocess data
 
 In this dataset, all red dots are gathered in the center. So we can set a number *L* such that all *𝒙² + 𝒚² ≤ L* points are red and all *𝒙² + 𝒚² > L* points are white.
 
 As there is just one unknown argument *L*, we can use linear classification.
 
 ![rawprocessed](rawprocessed.png)
 */

/*:
 - Experiment:
 Use linear classification to solve this problem:
 
    1. Tap the setting button on the upper right of the playground.
    2. Adjust the input layer on the left part of the setting view. Lit up the 𝒙² and 𝒚², and extinguish the 𝒙 and 𝒚.
    3. Remove all hidden layers in the network.
    4. Train again.
 */

//: [Next: Fun Time](@next)

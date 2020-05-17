//: [Previous: Linear Classification](@previous)

/*:
 ## Multilayer Network
 
 It is clear that linear classification is so simple that it is not applicable in many cases.
 
 This time the dataset is more complex than the previous one. There are two parts of red dots. One on the left-bottom corner, the other on the right-top corner.
 
 If we use linear classification at this time, we won't get a good result.
 
 To solve this problem, we need to add more layers, which we call them *hidden layers*, between the input layer and the output layer.
 */

import SwiftUI
import PlaygroundSupport
//: - Note: If the size of the live view is too large for your screen, you can adjust the `scale` variable to `0.8` and run again.
let scale: CGFloat = 1.0

PlaygroundPage.current.liveView = MultilayerNetworkView(scale)

/*:
 - Experiment:
 Build a network with more layers to solve this problem. Our goal is putting all red dots in the red area and white dots in the white area
 
    1. Tap the red ⨁ button on the left, you will get a new layer between the input layer and the output layer.
    2. There are ⊖ and ⊕ buttons for the hidden layers, too. You can use them to adjust neurons in hidden layers.
    3. If you want to retrain the network, you can tap the `replay` button above the `play` button.
    
    New layer increase the complexity of the network and improve its ability.
 */

/*:
 - Callout(Training Information):
 There are two numbers, maybe you already noticed, on the upper right of the playground: *Epoch* and *Loss*.
 
    - *Epoch* means the iteration number of the network. If its value is 100, it means that the network has iterated 100 times.
    - *Loss* means how bad the output is. Higher value means worse performance.
 */

//: [Next: Data Preprocessing](@next)

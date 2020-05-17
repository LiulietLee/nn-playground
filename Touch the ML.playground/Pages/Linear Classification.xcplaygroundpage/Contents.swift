//: [Previous: Handwritten Digit Classifier](@previous)

/*:
 ## Linear Classification
 
 Here we begin with the simplest network, which only contains two inputs and one output, without *hidden layers*.
 
 ### Before we start
 We need to know the meanings of some important parts in the playground.
 
 1. In this playground, we use **color** but not **numbers** to present values. The heat map as follow.
 
    ![heatmap](heatmap.png)

    As you see, red means positive values, and blue means negative values.
 
 2. Our network inputs a point (x, y) and predicts a real number. *Our goal* is to make the output value as close to the answer, or label, as possible.
 
    ![evolv](evolv.png)

    Dots in the fig represent samples. Their color represents the label. The top one is a bad output. We need to adjust parameters in the network to get the bottom output that red dots in the red area and white dots in the white area.
 */

import SwiftUI
import PlaygroundSupport
//: - Note: If the size of the live view is too large for your screen, you can adjust the `scale` variable to `0.8` and run again.
let scale: CGFloat = 1.0

PlaygroundPage.current.liveView = LinearClassificationView(scale)

/*:
 
 - Experiment:
 Train a linear classifier.
 
    1. At the beginning the parameters are randomly chosen, so we got a bad result.
    2. Tap the triangular play button on the right, the network will adjust its parameters very quickly and get a much better output.
 
    You can see the shape of output looks like one line cuts the rectangle. The reason is that there is just one layer in the network, which makes it can only do some simple predictions.
 */

/*:
 - Callout(Wait, where is the blue color in the output?):
 There is another question: there's no blue color in the output. That because we use a function called `Leaky ReLU`, 𝒚 = max{0.0001𝒙, 𝒙}. If the 𝒙 is less than zero, its output 𝒚 will be very close to zero, which represented by white color.
 
    ![leakyrelu](leakyrelu.jpg)
 
    It was introduced in a paper called *Delving Deep into Rectifiers*. However, the consistency of the benefit across tasks is presently unclear.
    
    Well, the word *unclear* is very common in machine learning.
 */

//: [Next: Multilayer Network](@next)

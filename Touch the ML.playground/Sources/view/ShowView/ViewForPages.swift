import SwiftUI
import PlaygroundSupport

public func LinearClassificationView(_ scale: CGFloat) -> UIHostingController<PlaygroundView> {
    let view = PlaygroundView(adjModel: false, adjLayer: false, useSetting: false, chgData: false, scale: scale, type: .linecut)
    let host = UIHostingController(rootView: view)
    host.preferredContentSize = CGSize(width: 700 * scale, height: 800 * scale)
    return host
}

public func MultilayerNetworkView(_ scale: CGFloat) -> UIHostingController<PlaygroundView> {
    let view = PlaygroundView(useSetting: false, chgData: false, scale: scale, type: .streak)
    let host = UIHostingController(rootView: view)
    host.preferredContentSize = CGSize(width: 700 * scale, height: 800 * scale)
    return host
}

public func DataPreprocessingView(_ scale: CGFloat) -> UIHostingController<PlaygroundView> {
    let view = PlaygroundView(chgData: false, scale: scale,modelDesc: [2, 4, 3], type: .center)
    let host = UIHostingController(rootView: view)
    host.preferredContentSize = CGSize(width: 700 * scale, height: 800 * scale)
    return host
}

public func FunTimeView(_ scale: CGFloat) -> UIHostingController<PlaygroundView> {
    let view = PlaygroundView(scale: scale)
    let host = UIHostingController(rootView: view)
    host.preferredContentSize = CGSize(width: 700 * scale, height: 800 * scale)
    return host
}

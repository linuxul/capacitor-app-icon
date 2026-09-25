import Foundation
import UIKit
import Capacitor

@objc(AppIconPlugin)
public class AppIconPlugin: CAPPlugin, CAPBridgedPlugin {
    public let identifier = "AppIconPlugin"
    public let jsName = "AppIcon"
    public let pluginMethods: [CAPPluginMethod] = [
        .async("isSupported", AppIconPlugin.isSupported),
        .async("getName", AppIconPlugin.getName),
        .promise("change", AppIconPlugin.change),
        .promise("reset", AppIconPlugin.reset)
    ]

    /// UIApplication is main-actor state: the method runs on the main actor instead of blocking the bridge queue on a
    /// DispatchQueue.main.sync.
    @MainActor
    func isSupported(_ call: CAPPluginCall) async -> JSObject {
        return [
            "value": UIApplication.shared.supportsAlternateIcons
        ]
    }

    /// Resolves with `{ value }`: the alternate icon's name, or null for the primary icon.
    @MainActor
    func getName(_ call: CAPPluginCall) async -> JSObject {
        return [
            "value": UIApplication.shared.alternateIconName ?? NSNull()
        ]
    }

    // change and reset stay synchronous: the bridge queue runs them in the order of the calls and each hands its
    // UIKit work to the main queue in that order, so the last call wins. Async methods would not keep that order.

    func reset(_ call: CAPPluginCall) {
        setIcon(iconName: nil, suppressNotification: false, call)
    }

    func change(_ call: CAPPluginCall) throws {
        let iconName = call.getString("name") ?? ""

        guard !iconName.isEmpty else {
            throw CAPPluginError("Must provide an icon name.")
        }

        setIcon(iconName: iconName, suppressNotification: false, call)
    }

    func setIcon(iconName: String?, suppressNotification: Bool = false, _ call: CAPPluginCall) {
        DispatchQueue.main.async {
            // Check if the app supports alternating icons
            guard UIApplication.shared.supportsAlternateIcons else {
                call.reject("Alternate icons not supported.")
                return
            }

            if suppressNotification {
                if UIApplication.shared.responds(to: #selector(getter: UIApplication.supportsAlternateIcons)) && UIApplication.shared.supportsAlternateIcons {
                    typealias SetAlternateIconName = @convention(c) (NSObject, Selector, NSString?, @escaping (NSError) -> Void) -> Void

                    let selectorString = "_setAlternateIconName:completionHandler:"

                    let selector = NSSelectorFromString(selectorString)
                    let imp = UIApplication.shared.method(for: selector)
                    let method = unsafeBitCast(imp, to: SetAlternateIconName.self)
                    method(UIApplication.shared, selector, iconName as NSString?, { _ in })

                    call.resolve()
                }

            } else {
                UIApplication.shared.setAlternateIconName(iconName) { error in
                    if let error = error {
                        call.reject(error.localizedDescription, nil, error)
                    } else {
                        call.resolve()
                    }
                }
            }
        }
    }
}

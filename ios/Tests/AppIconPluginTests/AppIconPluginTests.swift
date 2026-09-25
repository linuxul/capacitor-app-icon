import XCTest
import Capacitor
@testable import AppIconPlugin

class AppIconPluginTests: XCTestCase {
    func testBridgedMethods() {
        let plugin = AppIconPlugin()

        XCTAssertEqual(plugin.jsName, "AppIcon")
        XCTAssertEqual(plugin.pluginMethods.map { $0.name }, ["isSupported", "getName", "change", "reset"])
        XCTAssertEqual(plugin.pluginMethods.map { $0.returnType }, [.promise, .promise, .promise, .promise])
    }

    func testChangeWithoutANameIsRejected() {
        for options: JSObject in [[:], ["name": ""]] {
            let call = CAPPluginCall(callbackId: "test", methodName: "change", options: options, success: { _, _ in
                XCTFail("change must throw")
            }, error: { _ in
                XCTFail("change answers by throwing")
            })
            XCTAssertThrowsError(try AppIconPlugin().change(call)) { error in
                XCTAssertEqual((error as? CAPPluginError)?.message, "Must provide an icon name.")
                XCTAssertNil((error as? CAPPluginError)?.code)
            }
        }
    }
}

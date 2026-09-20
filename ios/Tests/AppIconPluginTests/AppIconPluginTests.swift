import XCTest
@testable import AppIconPlugin

class AppIconPluginTests: XCTestCase {
    func testBridgedMethods() {
        let plugin = AppIconPlugin()

        XCTAssertEqual(plugin.jsName, "AppIcon")
        XCTAssertEqual(plugin.pluginMethods.map { $0.name }, ["isSupported", "getName", "change", "reset"])
        XCTAssertEqual(plugin.pluginMethods.map { $0.returnType }, [.promise, .promise, .promise, .promise])
    }
}

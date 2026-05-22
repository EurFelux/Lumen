import Foundation

public protocol AppleScriptRunnerProtocol {
    func run(script: String) -> Bool
}

public final class AppleScriptRunner: AppleScriptRunnerProtocol {
    public init() {}

    public func run(script: String) -> Bool {
        var error: NSDictionary?
        guard let appleScript = NSAppleScript(source: script) else { return false }
        appleScript.executeAndReturnError(&error)
        return error == nil
    }
}

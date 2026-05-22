import Foundation

public protocol DebounceTimerProtocol: AnyObject {
    func start()
    func cancel()
}

public final class DebounceTimer: DebounceTimerProtocol {
    private let duration: TimeInterval
    private let action: () -> Void
    private var workItem: DispatchWorkItem?

    public init(duration: TimeInterval, action: @escaping () -> Void) {
        self.duration = duration
        self.action = action
    }

    public func start() {
        cancel()
        let item = DispatchWorkItem(block: action)
        workItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: item)
    }

    public func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}

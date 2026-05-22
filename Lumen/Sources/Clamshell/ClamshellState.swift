import Foundation

/// Current clamshell (lid) state of the MacBook
public enum ClamshellState: Equatable {
    case open    // Lid open — ALS readings are valid
    case closed  // Lid closed — ALS readings are meaningless
}

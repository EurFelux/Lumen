import Cocoa

let options = CGWindowListOption(arrayLiteral: .optionAll)
let windowList = CGWindowListCopyWindowInfo(options, kCGNullWindowID) as? [[String: Any]] ?? []

for window in windowList {
    if let ownerName = window[kCGWindowOwnerName as String] as? String,
       let windowName = window[kCGWindowName as String] as? String,
       let bounds = window[kCGWindowBounds as String] as? [String: CGFloat],
       let ownerPID = window[kCGWindowOwnerPID as String] as? Int {
        let x = bounds["X"] ?? 0
        let y = bounds["Y"] ?? 0
        let w = bounds["Width"] ?? 0
        let h = bounds["Height"] ?? 0
        if y > -100 && y < 100 && w > 20 && w < 100 && h > 20 && h < 50 {
            print("PID: \(ownerPID), Owner: \(ownerName), Name: \(windowName), Bounds: (\(x), \(y), \(w), \(h))")
        }
    }
}
print("Done listing windows")

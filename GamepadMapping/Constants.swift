import Foundation

struct Constants {
    // Standard 600x800
    static let windowHeight = 600
    static let windowWidth = 800
    
    // Maps standard macOS keycodes to english key names
    static let KeyCodeToKeyName: [UInt16: String] = [
        36: "Return",
        48: "Tab",
        49: "Space",
        51: "Backspace",
        53: "Escape",
        76: "Enter",
        115: "Home",
        116: "Page up",
        117: "Delete",
        119: "End",
        121: "Page down",
        123: "Left",
        124: "Right",
        125: "Down",
        126: "Up"
    ]

    // Associates controler button english names to their HID IDs -- These IDs were extracted by tailing the HID output.
    // Order is important, which is why a list of tuples was used instead of a dictionary directly.
    static let controllerButtonNameAndId = [
        ("A", "a.circle"),
        ("B", "b.circle"),
        ("X", "x.circle"),
        ("Y", "y.circle"),
        ("Left 1", "lb.rectangle.roundedbottom"),
        ("Left 2", "lt.rectangle.roundedtop"),
        ("Right 1", "rb.rectangle.roundedbottom"),
        ("Right 2", "rt.rectangle.roundedtop"),
        ("Left Stick", "l.joystick.down"),
        ("Right Stick", "r.joystick.press.down"),
        ("Select", "rectangle.fill.on.rectangle.fill.circle"),
        ("Start", "line.horizontal.3.circle")
    ]
    static let controllerButtonNameToId = Dictionary(uniqueKeysWithValues: Constants.controllerButtonNameAndId)
    // Factor in the a <> b and x <> y swaps
    static let controllerButtonIdToNameAfterSelectiveSwaps = Dictionary(uniqueKeysWithValues: Constants.controllerButtonNameAndId.map { tup in
        let name = tup.0
        let id = tup.1
        if name == "A" { return (controllerButtonNameToId["B"], name) }
        else if name == "B" { return (controllerButtonNameToId["A"], name) }
        else if name == "X" { return (controllerButtonNameToId["Y"], name) }
        else if name == "Y" { return (controllerButtonNameToId["X"], name) }
        else { return (id, name) }
    })
}

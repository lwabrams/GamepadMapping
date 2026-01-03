# Gamepad to Keyboard/Mouse Mapping

A minimal, customizable, and easy to use macOS utility to map Game Controller inputs to Keyboard and Mouse events. This allows users to use a gamepad with applications or games that do not natively support controllers (e.g., Minecraft Java Edition).

## Features

Input mapping:
*   **Button Mapping:** Map any controller button to a keyboard key, mouse button, or scroll wheel action.
*   **Direction Pad Mapping:** Map presses on the controller's direction pad to keyboard keys, mouse buttons, or scroll wheel actions.
*   **Stick Mapping:** Map stick movement in onw of two ways -
    *   **Mouse Mode:** Control the mouse cursor with a controller stick. Includes sensitivity control, and a setting to provide compatibiltiy with immersive games that capture the mouse.
    *   **Direction Pad Mode:** Simulate directional key presses (up, down, left, right) using controller stick movement.
*   **Nintendo Layout Support:** Nintendo controller layouts can invert the positioning of a/b, and x/y. A toggle is provided to swap A/B and X/Y if necessary.

Support functionality:
*   **Button Identification:** With this app in the foreground pressing a controller button or rotating a stick will highlight that input in the app.
*   **Profile Management:** Create, rename, and switch between multiple mapping configurations (profiles) for different games or use cases.
*   **Profile Persistence:** Mappings and settings are automatically saved between sessions.
*   **Simulation Log:** Provides a real-time view of generated input events for debugging as mapped controller inputs are pressed.

## Prerequisites

## 1. Accessibility Permissions
To function properly and simulate keyboard and mouse events for other running applications, this application requires **Accessibility** permissions. To achive this:
1.  Open **System Settings** > **Privacy & Security** > **Accessibility**.
2.  Add the **GamepadMapping** app to the list and enable it.
3.  **Important:** If you rebuild or reinstall the app, macOS may treat it as a new binary. You often need to remove the old entry (using the `-` button) and add it again if input stops working.

### 2. Sandbox (only if building directly from source)
This app consumes raw controller input and simulates key and mouse events into the event queue. When building from source, ensure the **App Sandbox** capability is **disabled** in the Xcode project settings (Signing & Capabilities).

## Usage

1.  **Connect Controller:** Connect your Bluetooth or USB controller (Xbox, PlayStation, Switch Pro, etc.). It should be automatically detected. If it's an incompatible controller you will see a respective message.
2.  **Profile Management:**
    *   Use the dropdown menu at the top to switch between different mapping profiles.
    *   Click the text field next to the dropdown to rename the current profile.
    *   Use the menu options within the dropdown to create a new profile or delete the current one.
3.  **Mapping Buttons:**
    *   Click on any row in the "Direction Pad" or "Buttons" columns.
    *   A modal will appear. Press the desired Key, Mouse Button, or scroll the Scroll Wheel up or down to assign a mapping.
    *   Clicking the "X" button next to a mapping will clear it.
4.  **Configuring Sticks:**
    *   Use the dropdowns in the "Axes" column to select a mode for the Left and Right sticks.
    *   **Map to mouse axes:** Simulates mouse movement.
        *   **Speed:** Adjusts cursor sensitivity.
        *   **Delta only:**
            *   **Enabled:** Moves the system cursor visible on the desktop. Best for general app usage.
            *   **Disabled:** Submits only movement deltas without moving the cursor location itself. **Use this for immersive/first-person games** (such as Minecraft) that capture the mouse. This prevents the hidden cursor from hitting the screen boundary and stopping your view rotation.
    *   **Simulate a direction pad:** Reduces stick movement to up, down, left, or right, and provides mapping for the directions o keys (useful for WASD movement).
5.  **Simulation:**
    *   Input simulation is active only when the app is running **and** the app is not the foreground window. In other words, to activate mapping simply have the app open and navigate to another app and use the controller.
    *   The "Simulation Log" at the bottom shows events generated while the app is in the foreground for debugging purposes.

## Nuances & Troubleshooting

*   **Input not working in game:**
    *   Ensure the app is open and in the background (the game is in focus).
    *   Verify Accessibility permissions are granted. (See the note above).
*   **Mouse stops moving in game:**
    *   If your character stops turning after rotating about 180 degrees, the hidden mouse cursor is likely hitting the edge of the screen. Ensure **"Delta only"** is checked for the stick mapaped to mouse motion.
*   **Wrong Buttons (A/B swapped):**
    *   If you are using a Nintendo Switch Pro Controller (or similar), the A/B and X/Y buttons might be swapped compared to the system default. Enable the **"Swap A/B & X/Y"** toggle in the Buttons column to correct this.

## Constraints and Limitations

* At present the app only supports a single controller being plugged in.
* The app primarily supports controllers that macOS categorizes as "extended gamepads" (https://developer.apple.com/documentation/GameController/GCExtendedGamepad). This should encompass Xbox controllers, most modern console controllers, and controllers created to mimic such controllers.
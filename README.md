# Show Pressed Keys

Show WASD and mouse overlay to show currently pressed keys. Drawn using GDI+ lib. Intended for use when streaming on Twitch.tv.

This project contains 2 scripts:

- wasd-overlay.ahk - Shows WASD, Ctrl, Space, Q, and E in overlay
- mouse-overlay.ahk - Highlights the pressed key on an image of a mouse (default is a Logitech G400)

Preview of it in action (bottom right of screen):

[![Show Pressed Keys](http://img.youtube.com/vi/wKHAsfyKZ-M/0.jpg)](https://www.youtube.com/watch?v=wKHAsfyKZ-M)

## Usage

1. Modify `posX` and `posY` as needed
2. Run `wasd-overlay.ahk` and/or `mouse-overlay.ahk`
3. In OBS, use Screen Capture and Chromakey on the green background

## To Do

- Add scrollwheel up and down to mouse overlay
- Implement Ini loading for settings
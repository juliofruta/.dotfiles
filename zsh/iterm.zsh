# @description Opens and positions iTerm at the current directory,
# maintaining the current font size by using the default profile.
# The window is centered and sized to 800x600 pixels.
function itermhere() {
    # Get the current directory and quote it for safe shell execution
    local quoted_dir=$(printf "%q" "$(pwd)")

    # AppleScript to create, position, and size the new iTerm window
    osascript -e "
    tell application \"iTerm\"
        activate
        set new_window to (create window with default profile)
        tell new_window
            tell current session
                write text \"cd ${quoted_dir} && clear\"
            end tell
            # Get screen dimensions to center the window
            tell application \"Finder\"
                set screen_resolution to bounds of window of desktop
                set screen_width to item 3 of screen_resolution
                set screen_height to item 4 of screen_resolution
            end tell
            set window_width to 800
            set window_height to 600
            set x_pos to (screen_width - window_width) / 2
            set y_pos to (screen_height - window_height) / 2
            set bounds to {x_pos, y_pos, x_pos + window_width, y_pos + window_height}
        end tell
    end tell
    "
}


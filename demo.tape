# SwiftONVIF Demo GIF
# Records discovery + direct connection against real Axis hardware

Output demo.gif

Set Shell "zsh"
Set FontSize 15
Set Width 880
Set Height 520
Set Theme "Catppuccin Mocha"
Set Padding 20
Set TypingSpeed 50ms
Set PlaybackSpeed 1

# Navigate to project
Hide
Type "cd ~/swift-onvif && swift build -q 2>/dev/null"
Enter
Sleep 5s
Show

Sleep 500ms

# --- Part 1: Discovery ---
Type "# 1) Discover ONVIF cameras on the local network"
Enter
Sleep 800ms

Type "swift run -q ONVIFExplorer"
Enter
Sleep 9s

# Pause to read results
Sleep 2500ms

# --- Part 2: Direct Connection ---
Type "# 2) Query a specific camera with credentials"
Enter
Sleep 800ms

Type "swift run -q ONVIFExplorer 192.168.1.33 root pass"
Enter
Sleep 10s

# Pause to read results
Sleep 3s

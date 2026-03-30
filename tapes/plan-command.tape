# Plan Command Demo
# Strategy: Use short sleeps so the GIF only captures key moments.
# VHS records the screen regardless of whether Claude finished.
# The viewer sees typing → output appearing → done. No dead air.

Output images/plan-command.gif
Set FontSize 14
Set Width 1400
Set Height 900
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 80ms
Set Shell "zsh"

# Start Claude
Type "claude"
Enter
Sleep 5s

# Type the command
Type "/plan Build a simple todo REST API"
Enter

# Record just enough to show output streaming in
Sleep 60s

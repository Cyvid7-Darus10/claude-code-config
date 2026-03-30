# Session Management Demo
# Records: /save-session and /resume-session workflow

Output images/session-management.gif
Set FontSize 16
Set Width 1200
Set Height 800
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 50ms
Set Shell "zsh"

Type "claude"
Enter
Sleep 3s

Type "/save-session"
Enter
Sleep 8s

# Simulate ending and restarting
Type "exit"
Enter
Sleep 2s

Type "claude"
Enter
Sleep 3s

Type "/resume-session"
Enter
Sleep 10s

Type "q"
Sleep 1s

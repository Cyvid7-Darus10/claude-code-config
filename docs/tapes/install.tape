# Install Script Demo
# Records: running the installer with colored output
# Run from repo root: vhs tapes/install.tape

Output images/install-demo.gif
Set FontSize 16
Set Width 1200
Set Height 800
Set Theme "Dracula"
Set Padding 20
Set TypingSpeed 50ms
Set Shell "zsh"

Type "./install.sh --dry-run"
Enter
Sleep 5s

Type ""
Enter
Sleep 1s

Type "./install.sh agents commands skills"
Enter
Sleep 8s

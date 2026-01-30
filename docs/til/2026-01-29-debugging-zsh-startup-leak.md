# TIL: Debugging Zsh Startup with Trace Mode

## 💡 The Problem
A recurring line of code was being appended to `~/.zshrc` on every terminal start, causing 30+ duplicate lines and slow shell performance. Traditional `grep` failed to find the source.

## 🛠️ The Solution Command
The command that revealed the "vandal" was:
`zsh -ixc "exit" 2>&1 | grep -B 5 "target-string"`

### Breakdown:
* **`-i` (Interactive):** Forces Zsh to load all RC files (`.zshrc`, etc.) as if you were opening a real terminal.
* **`-x` (Trace/X-ray):** Prints every command executed to `stderr`.
* **`-c "exit"`:** Tells the shell to run the command "exit" immediately after finishing the startup sequence.
* **`2>&1`:** Redirects the trace (which lives in stderr) to stdout so it can be filtered.

## 🧠 Key Insight
The trace revealed that **Chezmoi** and a logic loop in a sourced `helpers.sh` were dynamically echoing lines into the config file. By seeing the line numbers in the trace (e.g., `+ /path/to/file:28`), I could pinpoint the exact origin of the leak.

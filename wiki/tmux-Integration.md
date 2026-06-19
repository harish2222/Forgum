# tmux Integration

This guide shows you how to display Forgum fortunes in your tmux status bar. Every time you look at the bottom of your terminal, you'll see a random quote!

## What is tmux?

tmux is a "terminal multiplexer" — it lets you split your terminal into multiple windows and keep them running. Many developers use it because it's powerful and customizable.

The **status bar** is the bar at the bottom of your terminal that shows information like the time, current program, etc. We can put a fortune there!

## Step 1: Make Sure You Have tmux

```bash
# Check if tmux is installed
tmux -V
```

If you see a version number, you're good. If not:
- **Mac**: `brew install tmux`
- **Linux**: `sudo apt install tmux` (Ubuntu/Debian) or `sudo yum install tmux` (CentOS/RHEL)

## Step 2: Make Sure PowerShell + Forgum Work

```bash
# Test that PowerShell and Forgum work
pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune"
```

You should see a quote. If not, go back to [Getting Started](Getting-Started).

## Step 3: Edit tmux Config

Open your tmux config file:

```bash
nano ~/.tmux.conf
```

Add these lines:

```bash
# ============================================
# Forgum Fortune in Status Bar
# ============================================

# Show a fortune in the bottom-right corner
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null)"

# Update the fortune every 5 minutes (300 seconds)
set -g status-interval 300

# Make the status bar look nice
set -g status-style bg=black,fg=white
set -g status-right-style fg=cyan
```

## Step 4: Reload tmux

```bash
# If tmux is already running
tmux source-file ~/.tmux.conf

# Or start a new tmux session
tmux new-session
```

## What You'll See

At the bottom-right of your terminal, you'll see something like:

```
0/0  bash  |  The best way to predict the future is to invent it.
```

Every 5 minutes, it shows a new fortune!

## Different Status Bar Styles

### Style 1: Just the Fortune

```bash
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null)"
```

### Style 2: Fortune + Time

```bash
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null) | %H:%M"
```

### Style 3: Cow + Fortune (Left Side)

```bash
set -g status-left "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text (Get-Fortune) -CowFile default' 2>/dev/null)"
```

### Style 4: Colored Fortune

```bash
set -g status-right "#[fg=cyan]#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune' 2>/dev/null)#[default]"
```

## How It Works

| Setting | What It Does |
|:--------|:-------------|
| `set -g status-right` | Sets the right side of the status bar |
| `#(...)` | Runs a command and shows its output |
| `2>/dev/null` | Hides error messages |
| `status-interval 300` | Updates every 5 minutes |
| `set -g status-style` | Sets colors for the status bar |

## Tips

### Use a Specific Cow

```bash
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; forgum -Text (Get-Fortune) -CowFile tux' 2>/dev/null)"
```

### Use Rainbow Colors

```bash
set -g status-right "#(pwsh -NoProfile -Command 'Import-Module Forgum -ErrorAction SilentlyContinue; `$config = Get-CFConfig; `$config.lolcat.enabled = `$true; Set-CFConfig -Config `$config; forgum' 2>/dev/null)"
```

### Update More Often

```bash
# Update every minute
set -g status-interval 60
```

### Update Less Often

```bash
# Update every 10 minutes
set -g status-interval 600
```

## Troubleshooting

**"pwsh: command not found"**
- PowerShell isn't installed. See the [Bash & Zsh Integration](Bash-Zsh-Integration) guide.

**Status bar shows nothing or errors**
- Test the command directly in your terminal first:
  ```bash
  pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; Get-Fortune"
  ```
- If that works but tmux doesn't, check for typos in your `~/.tmux.conf`.

**Fortune doesn't update**
- Make sure `status-interval` is set (in seconds).

**Status bar looks weird**
- You might have conflicting tmux settings. Try removing other `status-right` lines.

---

**Back:** [Fish Integration](Fish-Integration) | **Next:** [Configuration →](Configuration)

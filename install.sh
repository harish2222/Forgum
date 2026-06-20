#!/usr/bin/env bash
# Forgum Installer — fun, animated, cross-platform
# Usage: bash <(curl -fsSL https://raw.githubusercontent.com/harish2222/Forgum/main/install.sh)

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'
BOLD='\033[1m'

# Fun phrases
PHRASES=(
    "Moo! Let's install some cow wisdom."
    "The cow has spoken. You need this."
    "Fortune favors the bold. And the installed."
    "Your terminal is about to get a personality upgrade."
    "Warning: May cause excessive cow puns."
    "One does not simply install cowsay... just kidding, it's easy."
    "Cow power: ACTIVATED."
    "Installing happiness, one moo at a time."
    "This is the way. The cow way."
    "You're one install away from enlightenment."
    "The cow gods smile upon you today."
    "Abandon your boring terminal, all ye who install here."
    "Cow say: 'You have excellent taste.'"
    "Loading wisdom... please moo politely."
    "Your terminal called. It wants a cow."
    "Fortune cookies are so last century. We have fortune cows."
    "Moo-velous! You're making a great decision."
    "Installing... because plain text is boring."
    "The cow is mightier than the sword."
    "You had me at moo."
    "Cow-llaboration makes the dream work."
    "This install is udderly fantastic."
    "Don't have a cow, man. Just install it."
    "Holy cow, that was a good pun."
    "I'm not lion... wait, wrong animal. Moo!"
    "Cow-culate the odds: 100% awesome."
    "You're moooving up in the world."
    "Let's get this bread... er, this hay."
    "Cow-abunga, dude!"
    "It's a moo-point anyway. Just install it."
    "I've got 99 problems but a cow ain't one."
    "Cow-perative installation in progress..."
    "E-I-E-I-O and a moo-moo here..."
    "The cow says: 'I'll make your day.'"
    "Spreading the moosic of wisdom."
    "You can't HANDLE the moo! ...ok you can."
    "Houston, we have a cow."
    "That's one small moo for man, one giant moo for mankind."
    "Life, uh, finds a way. A cow way."
    "To moo or not to moo? That is not a question."
    "Winter is coming. But so is your cow."
    "I am the one who moos."
    "Say hello to my little cow."
    "Moo-tator approved!"
    "Keep calm and moo on."
    "May the moo be with you."
    "Live long and prosper... and moorish."
    "Here's looking at you, cow."
    "You talkin' to me? ...moo."
    "I'll be bock. With more cows."
)

# Cow faces for progress animation
COW_FACES=(
    "  ^__^
   (oo)\\_______
   (__)\\       )\\/\\
       ||----w |
       ||     ||"

    "  ^__^
   (oo)\\_______
   (--)\\       )\\/\\
       ||----w |
       ||     ||"

    "  ^__^
   (OO)\\_______
   (oo)\\       )\\/\\
       ||----w |
       ||     ||"

    "   \\   /^\\
    \\|| o  o |
     (oo)\\___/
     (__) )/\\
      || ||
      ^^^ ^^^"

    "   .-***-.
  /        \\
 |  O    O  |
 |    __    |
  \\  \\__/  /
   '-.  .-'
      \\|
       |
      /|\\
     / | \\"

    "      \\       /
       \\  ===  /
        \\     /
     /'''---'''\\
    /  |||||||  \\
   /   |||||||   \\
       |||||||
       |||||||
"

    "        ,-.____,-.
       /         \\
      |  o     o  |
      |     __    |
       \\   \\/   /
        '-.  .-'
          |  |
          /  \\
         /    \\
        /  ||  \\
       /   ||   \\"

    "        .---.
       /       \\
      |  O   O  |
      |    ^    |
      |   '-'   |
       \\       /
        '-----'
       ____| |____
      /    | |    \\
     /     | |     \\
            |"
)

# Spinner characters
SPINNER=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")

# ---- Functions ----

show_banner() {
    echo ""
    echo -e "${CYAN}${BOLD}"
    cat << 'EOF'
  _____ _____ ___ _____ ___ ___  _  ___
 /  ___|  ___/ _ \_   _|_ _/ _ \| |/ /
 \ `--. | |_ / /_\ \| |  | | | | ' / 
  `--. \|  _||  _  || |  | | | | . \ 
 /\__/ /| |  | | | || | _| |_| | |\ \
 \____/ \_|  \_| |_/\_/ |___/ \_| |_/
EOF
    echo -e "${NC}"
    echo -e "  ${CYAN}${PHRASES[$RANDOM % ${#PHRASES[@]}]}${NC}"
    echo ""
}

spinner() {
    local pid=$1
    local msg=$2
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        echo -ne "\r  ${CYAN}${SPINNER[$((i % ${#SPINNER[@]}))]}${NC} ${msg}  "
        i=$((i + 1))
        sleep 0.1
    done
    echo -ne "\r"
}

progress_bar() {
    local current=$1
    local total=$2
    local width=40
    local pct=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))

    printf "\r  ${CYAN}["
    printf "%0.s█" $(seq 1 $filled 2>/dev/null) || true
    printf "%0.s░" $(seq 1 $empty 2>/dev/null) || true
    printf "]${NC} %3d%%" "$pct"
}

check_command() {
    command -v "$1" &>/dev/null
}

detect_platform() {
    case "$(uname -s)" in
        Linux*)   echo "linux";;
        Darwin*)  echo "macos";;
        CYGWIN*|MINGW*|MSYS*) echo "windows";;
        *)        echo "unknown";;
    esac
}

install_powershell() {
    local platform=$1
    echo -e "\n${YELLOW}  Checking for PowerShell...${NC}"

    if check_command pwsh; then
        echo -e "  ${GREEN}✓${NC} PowerShell already installed: $(pwsh --version | head -1)"
        return 0
    fi

    echo -e "  ${YELLOW}Installing PowerShell...${NC}"

    case $platform in
        linux)
            if check_command apt-get; then
                sudo apt-get update -qq && sudo apt-get install -y -qq powershell
            elif check_command dnf; then
                sudo dnf install -y powershell
            elif check_command pacman; then
                sudo pacman -S --noconfirm powershell
            else
                echo -e "  ${RED}✗ Could not detect package manager. Install PowerShell manually.${NC}"
                echo -e "  ${CYAN}  https://github.com/PowerShell/PowerShell#${platform}${NC}"
                return 1
            fi
            ;;
        macos)
            if check_command brew; then
                brew install --cask powershell
            else
                echo -e "  ${RED}✗ Homebrew not found. Install it from https://brew.sh${NC}"
                return 1
            fi
            ;;
        *)
            echo -e "  ${RED}✗ Auto-install not supported on this platform.${NC}"
            echo -e "  ${CYAN}  Install from: https://github.com/PowerShell/PowerShell/releases${NC}"
            return 1
            ;;
    esac
}

install_module() {
    echo -e "\n${YELLOW}  Installing Forgum module...${NC}"

    local platform
    platform=$(detect_platform)

    local module_dir
    if [ "$platform" = "windows" ] || [ "$platform" = "macos" ]; then
        if check_command pwsh; then
            module_dir=$(pwsh -NoProfile -Command '[Environment]::GetFolderPath("MyDocuments") + "/PowerShell/Modules/Forgum"' 2>/dev/null)
        fi
    fi

    if [ -z "$module_dir" ]; then
        module_dir="$HOME/.local/share/powershell/Modules/Forgum"
    fi

    local repo_url="https://github.com/harish2222/Forgum/archive/refs/heads/main.zip"
    local tmp_zip="/tmp/Forgum_$$.zip"

    echo -e "  Downloading from GitHub..."
    if check_command curl; then
        curl -fsSL "$repo_url" -o "$tmp_zip"
    elif check_command wget; then
        wget -q "$repo_url" -O "$tmp_zip"
    else
        echo -e "  ${RED}✗ Neither curl nor wget found.${NC}"
        return 1
    fi

    echo -e "  Extracting..."
    local tmp_dir="/tmp/Forgum_extract_$$"
    mkdir -p "$tmp_dir"

    if check_command unzip; then
        unzip -q "$tmp_zip" -d "$tmp_dir"
    else
        tar -xf "$tmp_zip" -C "$tmp_dir" 2>/dev/null
    fi

    local extracted="$tmp_dir/Forgum-main"

    if [ ! -d "$extracted" ]; then
        echo -e "  ${RED}✗ Extraction failed.${NC}"
        return 1
    fi

    mkdir -p "$(dirname "$module_dir")"
    rm -rf "$module_dir"
    mv "$extracted" "$module_dir"

    # Cleanup
    rm -rf "$tmp_zip" "$tmp_dir"

    echo -e "  ${GREEN}✓${NC} Module installed to: $module_dir"
}

setup_profile() {
    echo -e "\n${YELLOW}  Setting up shell profile...${NC}"

    local profiles=()
    [ -f "$HOME/.bashrc" ] && profiles+=("$HOME/.bashrc")
    [ -f "$HOME/.zshrc" ] && profiles+=("$HOME/.zshrc")
    [ -f "$HOME/.config/fish/config.fish" ] && profiles+=("$HOME/.config/fish/config.fish")

    local marker="# Forgum"

    for profile in "${profiles[@]}"; do
        if grep -q "$marker" "$profile" 2>/dev/null; then
            echo -e "  ${GREEN}✓${NC} Already configured: $profile"
            continue
        fi

        local profile_name=$(basename "$profile")

        if [ "$profile_name" = "config.fish" ]; then
            cat >> "$profile" << 'FISH'

# Forgum
function fish_greeting
    pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; forgum" 2>/dev/null
end
FISH
        else
            cat >> "$profile" << 'SHELL'

# Forgum (requires animation.mode = "static" in config to avoid startup hang)
if command -v pwsh &>/dev/null; then
    if [ -t 1 ]; then
        pwsh -NoProfile -Command "Import-Module Forgum -ErrorAction SilentlyContinue; \$cfg = Get-CFConfig 2>\$null; if (\$cfg -and \$cfg.animation.mode -eq 'static') { forgum }" 2>/dev/null
    fi
fi
SHELL
        fi

        echo -e "  ${GREEN}✓${NC} Configured: $profile"
    done
}

install_pester() {
    echo -e "\n${YELLOW}  Installing Pester (test framework)...${NC}"

    if pwsh -NoProfile -Command 'Get-Module -ListAvailable Pester | Where-Object Version.Major -ge 5' 2>/dev/null | grep -q "Pester"; then
        echo -e "  ${GREEN}✓${NC} Pester already installed"
        return 0
    fi

    pwsh -NoProfile -Command "Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser -MinimumVersion 5.0.0" 2>/dev/null
    echo -e "  ${GREEN}✓${NC} Pester installed"
}

run_tests() {
    echo -e "\n${YELLOW}  Running test suite...${NC}"

    local test_dir
    if check_command pwsh; then
        test_dir=$(pwsh -NoProfile -Command '[Environment]::GetFolderPath("MyDocuments") + "/PowerShell/Modules/Forgum"' 2>/dev/null)
    fi

    if [ -z "$test_dir" ] || [ ! -d "$test_dir/Tests" ]; then
        echo -e "  ${YELLOW}⚠ Tests directory not found, skipping.${NC}"
        return 0
    fi

    local result
    result=$(pwsh -NoProfile -Command "
        Import-Module Pester
        \$r = Invoke-Pester -Path (Join-Path \$test_dir 'Tests' 'Forgum.Tests.ps1') -PassThru
        Write-Output \"\$(\$r.PassedCount)/\$(\$r.TotalCount) passed\"
        if (\$r.FailedCount -gt 0) { exit 1 }
    " 2>&1)

    if echo "$result" | grep -q "passed"; then
        local count=$(echo "$result" | grep -oP '\d+/\d+' | tail -1)
        echo -e "  ${GREEN}✓${NC} Tests: $count"
    else
        echo -e "  ${YELLOW}⚠ Some tests failed. Run manually to debug.${NC}"
    fi
}

show_cow() {
    local face_idx=$((RANDOM % ${#COW_FACES[@]}))
    echo ""
    echo -e "${CYAN}${COW_FACES[$face_idx]}${NC}"
    echo ""
}

# ---- Main ----

main() {
    clear
    show_banner

    echo -e "${BOLD}  Welcome to the Forgum installer!${NC}"
    echo -e "  This will install cowsay + fortune + lolcat for PowerShell."
    echo ""

    local platform=$(detect_platform)
    echo -e "  Platform detected: ${CYAN}${platform}${NC}"

    # Step 1: Install PowerShell
    echo -e "\n${BOLD}━━━ Step 1/5: PowerShell ━━━${NC}"
    if ! install_powershell "$platform"; then
        echo -e "\n${RED}Failed to install PowerShell. Please install manually and re-run.${NC}"
        exit 1
    fi

    # Step 2: Install Pester
    echo -e "\n${BOLD}━━━ Step 2/5: Pester ━━━${NC}"
    install_pester

    # Step 3: Install Module
    echo -e "\n${BOLD}━━━ Step 3/5: Forgum Module ━━━${NC}"
    if ! install_module; then
        echo -e "\n${RED}Failed to install module.${NC}"
        exit 1
    fi

    # Step 4: Setup Profile
    echo -e "\n${BOLD}━━━ Step 4/5: Shell Profile ━━━${NC}"
    setup_profile

    # Step 5: Verify
    echo -e "\n${BOLD}━━━ Step 5/5: Verification ━━━${NC}"
    run_tests

    # Interactive Setup Prompt
    echo ""
    echo -e "${CYAN}${BOLD}Do you want to configure Forgum now? [Y/n]${NC}"
    read -r run_setup
    if [[ -z "$run_setup" || "$run_setup" =~ ^[Yy]$ ]]; then
        if check_command pwsh; then
            pwsh -c "Import-Module Forgum; forgum interactive"
        else
            local pwsh_path=""
            for p in "/usr/bin/pwsh" "/usr/local/bin/pwsh" "/snap/bin/pwsh" "/opt/microsoft/powershell/7/pwsh"; do
                if [ -x "$p" ]; then
                    pwsh_path="$p"
                    break
                fi
            done
            if [ -n "$pwsh_path" ]; then
                "$pwsh_path" -c "Import-Module Forgum; forgum interactive"
            else
                echo -e "  ${YELLOW}⚠ PowerShell (pwsh) not found in PATH. Please restart your shell and run 'forgum interactive'.${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}You can run 'forgum interactive' later to configure your experience.${NC}"
    fi

    # Done!
    show_cow

    echo -e "${GREEN}${BOLD}  Installation complete!${NC}"
    echo ""
    echo -e "  ${CYAN}Quick start:${NC}"
    echo -e "    pwsh -Command \"Import-Module Forgum; forgum\""
    echo ""
    echo -e "  ${CYAN}Commands:${NC}"
    echo -e "    forgum                   # Show a cow with a fortune"
    echo -e "    forgum cowsay 'Hello'    # Show a cow with custom text"
    echo -e "    forgum list              # List available cow templates"
    echo -e "    forgum interactive       # Open interactive config menu"
    echo -e "    forgum help              # Show all commands"
    echo ""
    echo -e "  ${CYAN}Config:${NC}"
    echo -e "    forgum config show       # View current config"
    echo -e "    forgum config path       # Show config file path"
    echo ""
    echo -e "  ${CYAN}Uninstall:${NC}"
    echo -e "    rm -rf ~/Documents/PowerShell/Modules/Forgum"
    echo -e "    rm -rf ~/.local/share/powershell/Modules/Forgum"
    echo ""

    local final_phrase="${PHRASES[$RANDOM % ${#PHRASES[@]}]}"
    echo -e "  ${MAGENTA}${BOLD}${final_phrase}${NC}"
    echo ""
}

main "$@"

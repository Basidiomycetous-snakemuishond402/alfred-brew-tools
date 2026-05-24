#!/usr/bin/env bash

# Brew Updater — Alfred Run Script wrapper
#
# Paste this whole file into Alfred's "Run Script" action.
#
# Alfred setup:
#   Keyword → Run Script
#   Language: /bin/bash
#
# Requires:
#   brew install tmux
#
# Optional:
#   brew install mas
#
# This opens Terminal, starts a tmux session with a fixed header,
# runs Homebrew/macOS App Store updates in the lower pane,
# then exits cleanly.

TMP_ID="$$-$(date +%s)"
SESSION_NAME="brew-updater-${TMP_ID}"
TMP_SCRIPT="/tmp/alfred-brew-updater-${TMP_ID}.sh"
TMP_HEADER="/tmp/alfred-brew-updater-header-${TMP_ID}.sh"
TMP_DONE="/tmp/alfred-brew-updater-done-${TMP_ID}.marker"
TMP_COMMAND="/tmp/alfred-brew-updater-${TMP_ID}.command"

cat > "$TMP_HEADER" <<'HEADER_EOF'
#!/usr/bin/env bash

while true; do
    clear
    printf '╭─ 🍺 Brew Updater ─────────────────────────────────────────────────────────╮\n'
    printf '│ Update Homebrew, upgrade formulae/casks, update App Store apps, cleanup   │\n'
    printf '│ Running updates now · Esc/Ctrl-C exits tmux if needed                     │\n'
    printf '╰───────────────────────────────────────────────────────────────────────────╯\n'
    sleep 3600
done
HEADER_EOF

cat > "$TMP_SCRIPT" <<'SCRIPT_EOF'
#!/usr/bin/env bash

SESSION_NAME="${1:-}"

has() {
    command -v "$1" >/dev/null 2>&1
}

section() {
    printf '\n\033[35m%s\033[0m\n' "$1"
}

ok() {
    printf '  \033[32m✅ %s\033[0m\n' "$1"
}

warn() {
    printf '  \033[33m⚠️  %s\033[0m\n' "$1"
}

fail() {
    printf '  \033[31m❌ %s\033[0m\n' "$1"
}

note() {
    printf '  \033[90m%s\033[0m\n' "$1"
}

close_app() {
    if [ -n "${SESSION_NAME:-}" ] && has tmux; then
        tmux kill-session -t "$SESSION_NAME" >/dev/null 2>&1 || true
    fi
    exit 0
}

finish_and_close() {
    section "Done"
    note "Closing shortly…"
    sleep 1.2
    close_app
}

run_with_timeout() {
    local timeout_secs="$1"
    shift

    local tmpfile
    local cmd_pid
    local watcher_pid
    local exit_code

    tmpfile="$(mktemp)"

    "$@" >"$tmpfile" 2>&1 &
    cmd_pid=$!

    ( sleep "$timeout_secs" && kill -9 "$cmd_pid" 2>/dev/null ) &
    watcher_pid=$!

    wait "$cmd_pid" 2>/dev/null
    exit_code=$?

    kill "$watcher_pid" 2>/dev/null || true
    wait "$watcher_pid" 2>/dev/null || true

    cat "$tmpfile"
    rm -f "$tmpfile"

    if [ "$exit_code" = "137" ]; then
        return 124
    fi

    return "$exit_code"
}

pluralise() {
    local count="$1"
    local singular="$2"
    local plural="$3"

    if [ "$count" = "1" ]; then
        printf '1 %s' "$singular"
    else
        printf '%s %s' "$count" "$plural"
    fi
}

join_parts() {
    # Joins arguments like:
    #   a
    #   a and b
    #   a, b, and c
    local count="$#"

    if [ "$count" -eq 0 ]; then
        return
    elif [ "$count" -eq 1 ]; then
        printf '%s' "$1"
    elif [ "$count" -eq 2 ]; then
        printf '%s and %s' "$1" "$2"
    else
        local i=1
        local part
        for part in "$@"; do
            if [ "$i" -eq "$count" ]; then
                printf 'and %s' "$part"
            else
                printf '%s, ' "$part"
            fi
            i=$((i + 1))
        done
    fi
}

clear

section "Checking Homebrew"

if [ -x /opt/homebrew/bin/brew ]; then
    BREW=/opt/homebrew/bin/brew
elif [ -x /usr/local/bin/brew ]; then
    BREW=/usr/local/bin/brew
elif has brew; then
    BREW="$(command -v brew)"
else
    fail "Homebrew not found"
    finish_and_close
fi

eval "$("$BREW" shellenv)"

ok "Homebrew found: $BREW"

section "Updating Homebrew"

if "$BREW" update; then
    ok "brew update completed"
else
    fail "brew update failed"
    finish_and_close
fi

section "Checking outdated Homebrew items"

OUTDATED_FORMULAE="$("$BREW" outdated --formula --quiet 2>/dev/null | wc -l | tr -d ' ')"
OUTDATED_CASKS="$("$BREW" outdated --cask --greedy --quiet 2>/dev/null | wc -l | tr -d ' ')"

note "Formulae: $OUTDATED_FORMULAE outdated"
note "Casks:    $OUTDATED_CASKS outdated"

section "Checking Mac App Store apps"

MAS_AVAILABLE=0
MAS_TIMED_OUT=0
OUTDATED_MAS=0
MAS_LIST_BEFORE=""

if has mas; then
    MAS_AVAILABLE=1
    note "mas found. Checking App Store updates, with 15s timeout…"

    MAS_LIST_BEFORE="$(run_with_timeout 15 mas outdated)"
    MAS_OUTDATED_EXIT=$?

    if [ "$MAS_OUTDATED_EXIT" = "124" ]; then
        MAS_AVAILABLE=0
        MAS_TIMED_OUT=1
        warn "mas outdated timed out. Skipping App Store updates this run."
    elif [ "$MAS_OUTDATED_EXIT" != "0" ]; then
        MAS_AVAILABLE=0
        warn "mas outdated errored. Skipping App Store updates this run."
    else
        OUTDATED_MAS="$(echo "$MAS_LIST_BEFORE" | grep -c '[^[:space:]]')"
        note "App Store apps: $OUTDATED_MAS outdated"
    fi
else
    note "mas not installed. Skipping App Store updates."
fi

if [ "$OUTDATED_FORMULAE" = "0" ] && [ "$OUTDATED_CASKS" = "0" ] && [ "$OUTDATED_MAS" = "0" ]; then
    section "Result"
    if [ "$MAS_TIMED_OUT" = "1" ]; then
        ok "Homebrew is up to date. App Store check timed out and was skipped."
    else
        ok "Already up to date"
    fi
    finish_and_close
fi

FORMULA_RESULT=""
CASK_RESULT=""
MAS_RESULT=""

if [ "$OUTDATED_FORMULAE" != "0" ]; then
    section "Upgrading Homebrew formulae"

    if "$BREW" upgrade --formula; then
        FORMULA_RESULT="$(pluralise "$OUTDATED_FORMULAE" "formula" "formulae")"
        ok "Upgraded $FORMULA_RESULT"
    else
        FORMULA_RESULT="formula upgrade failed"
        fail "Formula upgrade failed"
    fi
fi

if [ "$OUTDATED_CASKS" != "0" ]; then
    section "Upgrading Homebrew casks"

    if "$BREW" upgrade --cask --greedy; then
        CASK_RESULT="$(pluralise "$OUTDATED_CASKS" "cask" "casks")"
        ok "Upgraded $CASK_RESULT"
    else
        CASK_RESULT="cask upgrade failed"
        fail "Cask upgrade failed"
    fi
fi

if [ "$MAS_AVAILABLE" = "1" ] && [ "$OUTDATED_MAS" != "0" ]; then
    section "Upgrading Mac App Store apps"

    run_with_timeout 300 mas upgrade
    MAS_UPGRADE_EXIT=$?

    if [ "$MAS_UPGRADE_EXIT" = "124" ]; then
        MAS_RESULT="App Store timed out"
        warn "App Store upgrade timed out"
    else
        note "Verifying App Store updates…"

        MAS_LIST_AFTER="$(run_with_timeout 90 mas outdated)"
        MAS_AFTER_EXIT=$?

        if [ "$MAS_AFTER_EXIT" != "0" ]; then
            MAS_RESULT="$(pluralise "$OUTDATED_MAS" "App Store app" "App Store apps")"
            ok "App Store upgrade command completed, but verification failed"
        else
            OUTDATED_MAS_AFTER="$(echo "$MAS_LIST_AFTER" | grep -c '[^[:space:]]')"
            UPGRADED=$((OUTDATED_MAS - OUTDATED_MAS_AFTER))

            if [ "$UPGRADED" -le 0 ]; then
                MAS_RESULT=""
                note "No App Store apps appear to have been upgraded. This may be a mas version mismatch false positive."
            else
                MAS_RESULT="$(pluralise "$UPGRADED" "App Store app" "App Store apps")"
                ok "Upgraded $MAS_RESULT"
            fi
        fi
    fi
fi

section "Cleaning up Homebrew"

if "$BREW" cleanup; then
    ok "Cleanup completed"
else
    warn "Cleanup failed"
fi

section "Result"

PARTS=()
[ -n "$FORMULA_RESULT" ] && PARTS+=("$FORMULA_RESULT")
[ -n "$CASK_RESULT" ] && PARTS+=("$CASK_RESULT")
[ -n "$MAS_RESULT" ] && PARTS+=("$MAS_RESULT")

COUNT=${#PARTS[@]}

if [ "$COUNT" -eq 0 ]; then
    ok "Already up to date"
else
    SUMMARY="$(join_parts "${PARTS[@]}")"
    ok "Updated $SUMMARY"
fi

finish_and_close
SCRIPT_EOF

chmod +x "$TMP_HEADER"
chmod +x "$TMP_SCRIPT"

cat > "$TMP_COMMAND" <<EOF
#!/usr/bin/env bash

resize_front_terminal_window() {
    osascript <<OSA >/dev/null 2>&1
tell application "Terminal"
    activate
    set bounds of front window to {140, 100, 1080, 720}
    try
        set number of columns of front window to 104
        set number of rows of front window to 30
    end try
end tell
OSA
}

resize_front_terminal_window
sleep 0.25
resize_front_terminal_window

if ! command -v tmux >/dev/null 2>&1; then
    echo "tmux is required for this version."
    echo "Install it with: brew install tmux"
    sleep 2
    touch "$TMP_DONE"
    rm -f "$TMP_SCRIPT" "$TMP_HEADER" "$TMP_COMMAND"
    exit 0
fi

tmux new-session -d -s "$SESSION_NAME" "$TMP_SCRIPT" "$SESSION_NAME"

tmux set-option -t "$SESSION_NAME" mouse on
tmux set-option -t "$SESSION_NAME" focus-events on
tmux set-option -t "$SESSION_NAME" escape-time 0
tmux set-option -t "$SESSION_NAME" status on

tmux split-window -v -b -l 4 -t "$SESSION_NAME":0.0 "$TMP_HEADER"
tmux select-pane -t "$SESSION_NAME":0.1
tmux attach-session -t "$SESSION_NAME"

touch "$TMP_DONE"
rm -f "$TMP_SCRIPT" "$TMP_HEADER" "$TMP_COMMAND"
exit 0
EOF

chmod +x "$TMP_COMMAND"
xattr -d com.apple.quarantine "$TMP_COMMAND" 2>/dev/null || true

# Open a dedicated Terminal window and remember its window id.
WINDOW_ID="$(
osascript <<OSA
tell application "Terminal"
    activate
    set newTab to do script "\"$TMP_COMMAND\""
    delay 0.2
    set targetWindow to front window
    return id of targetWindow
end tell
OSA
)"

# Alfred-side monitor:
# Wait until the .command script has exited cleanly, then close that exact window.
# Because the shell has already exited, Terminal should not show the
# "terminate running processes" warning.
(
    while [ ! -f "$TMP_DONE" ]; do
        sleep 0.25
    done

    sleep 0.4

    osascript <<OSA >/dev/null 2>&1
tell application "Terminal"
    try
        close (first window whose id is $WINDOW_ID)
    end try
end tell
OSA

    rm -f "$TMP_DONE"
) >/dev/null 2>&1 &

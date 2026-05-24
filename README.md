# Brew Tools for Alfred

An Alfred workflow with two Terminal/tmux helpers for Homebrew:

- **Brew Updater** (`brewup`) updates Homebrew, upgrades formulae and casks, optionally updates Mac App Store apps via `mas`, and runs cleanup.
- **Brew Adopter** (`brewa`) scans installed macOS apps and helps adopt matching apps into Homebrew Cask management.

## Requirements

```bash
brew install tmux
```

Recommended:

```bash
brew install gum jq
```

Optional:

```bash
brew install fzf mas
```

`gum` gives the Brew Adopter a nicer TUI. `fzf` is used as a fallback. `mas` enables Mac App Store update support in Brew Updater.

## Install

Download/import `Brew Tools.alfredworkflow` into Alfred.

## Keywords

| Keyword | Action |
|---|---|
| `brewup` | Update Homebrew, upgrade formulae/casks, optionally run `mas upgrade`, and cleanup |
| `brewa` | Find manually installed apps that can be adopted by Homebrew Cask |

## Brew Adopter ignore list

Ignored casks are stored at:

```text
~/.config/alfred-brew-adopt/ignored-casks.txt
```

Delete or edit that file to unignore items.

## Notes

The workflow creates temporary scripts in `/tmp`, opens a dedicated Terminal/tmux session, and cleans up after itself.

# Security Policy

## Supported Versions

Security updates are provided for the latest released version of **Brew Tools for Alfred**.

| Version | Supported |
|---|---|
| Latest release | ✅ |
| Older releases | ❌ |

Users are encouraged to update to the latest release before reporting an issue.

## Reporting a Vulnerability

Please do **not** open a public GitHub issue for a suspected security vulnerability.

Instead, report security issues using GitHub’s private vulnerability reporting feature, if available for this repository.

If private vulnerability reporting is not available, please open a GitHub issue with only a brief, non-sensitive summary and mark it clearly as a security concern. Do not include exploit details, proof-of-concept payloads, or sensitive local information in the public issue.

Please include, where safe to do so:

- A clear description of the issue
- The affected workflow, script, or command
- The expected impact
- General reproduction steps, avoiding sensitive details
- Your suggested fix, if you have one

I will aim to acknowledge reports within **7 days** and provide an update once the issue has been assessed.

## Scope

This policy applies to security issues in:

- The Alfred workflow files
- The embedded shell scripts
- The Homebrew updater workflow
- The Brew adopter workflow
- Handling of temporary files, cached data, and ignore lists

Examples of relevant security issues include:

- Unsafe handling of shell input
- Command injection vulnerabilities
- Insecure temporary file usage
- Unintended execution of arbitrary commands
- Accidental exposure of sensitive local paths or data
- Unsafe handling of downloaded or generated workflow files

## Out of Scope

The following are generally out of scope:

- Vulnerabilities in Homebrew, Alfred, macOS Terminal, tmux, gum, fzf, jq, or mas
- Issues caused by modified local scripts
- Problems caused by running the workflow with elevated privileges
- Social engineering or phishing scenarios
- General feature requests or usability issues

## Security Considerations

Brew Tools for Alfred runs local shell commands that can install, update, and manage software on your Mac. Users should review the scripts before running them and only install releases from this repository.

The workflow does **not** intentionally collect, transmit, or store personal data. It may store local configuration files such as ignored cask names under:

```text
~/.config/alfred-brew-adopt/

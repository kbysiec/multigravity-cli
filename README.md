<div align="center">
  <img src="assets/multigravity-logo.jpg" alt="Multigravity Logo" width="120" />

  # Multigravity

  **Multi-profile launcher for Google Antigravity on macOS**

  Run multiple isolated instances of Antigravity and Antigravity IDE simultaneously — each with its own Google account, while sharing extensions, settings, and MCP tools.
</div>

---

> [!IMPORTANT]
> **macOS Only:** Support for Windows and Linux has been removed in this version. Modern Google Antigravity on macOS uses a dual-app architecture (`Antigravity.app` desktop chat + `Antigravity IDE.app` code editor) combined with native macOS Keychain credential storage. Multigravity was rewritten specifically for macOS (Apple Silicon & Intel) to guarantee complete account isolation, credential separation, and seamless integration with macOS.

---

## ⚡ Why Multigravity?

Google Antigravity consists of two distinct applications:
1. **Antigravity.app** — the AI agent and chat desktop application
2. **Antigravity IDE.app** — the code editor (VS Code fork)

By default, Antigravity stores its authentication tokens globally in the macOS Keychain (`login.keychain-db`) and configuration under `~/.gemini/` and `~/Library/Application Support/`. This prevents you from running multiple Google accounts at the same time (e.g. personal, client, or corporate work accounts).

**Multigravity solves this completely:**
- 🔒 **Full Account Isolation** — Each profile uses an isolated, dedicated macOS Keychain (`login.keychain-db`) and private `.gemini` runtime directory. Your primary account remains untouched, and each profile remembers its own Google login.
- 💻 **IDE-First by Default** — Running `multigravity <profile>` immediately opens Antigravity IDE. Launch only Chat with `--chat`, or open both simultaneously with `--both`.
- 🧩 **Shared by Default** — Profiles share your installed IDE extensions, settings, keybindings, skills, plugins, and MCP configurations by default, isolating only login sessions and workspace history. Fully isolated clean-slate profiles are also supported (`--isolated`).
- 🖥️ **Native macOS Shortcuts** — Automatically generates `.app` bundles in `~/Applications/` with icons, fully discoverable in Spotlight, Raycast, and Alfred, and pinnable to the macOS Dock.
- ⚡ **Zero Conflict** — Launches both apps using isolated user data directories (`--user-data-dir`) and native binary wrappers, preventing Electron instance lock conflicts.

---

## 📦 Installation

Requirements: **macOS** (macOS 12+ on Apple Silicon or Intel) with Google Antigravity installed.

```bash
# Clone the repository
git clone https://github.com/kbysiec/multigravity-cli.git
cd multigravity-cli

# Run installer
./install.sh
```

The installer copies the binary to `~/.local/bin/multigravity` (or `/usr/local/bin` if writable) and sets up your `PATH`.

---

## 🚀 Quick Start

```bash
# 1. Verify your installation and environment
multigravity doctor

# 2. Create a new shared profile (e.g. work)
multigravity new work

# 3. Launch Antigravity IDE with this profile
multigravity work

# Or launch both IDE and Desktop Chat simultaneously:
multigravity work --both

# You can also open it via Spotlight (Cmd + Space):
# "Multigravity work.app"
```

When you first open a new profile, you will see a fresh onboarding screen where you can sign in with your secondary Google account. Your main account in the default Antigravity installation will stay completely unaffected.

---

## 🎮 Launch Modes

| Command | Action |
|---|---|
| `multigravity <name>` | Launches **Antigravity IDE** (default mode) |
| `multigravity <name> --ide` | Launches only Antigravity IDE |
| `multigravity <name> --chat` (or `--app`) | Launches only Antigravity Desktop (Chat) |
| `multigravity <name> --both` (or `--all`) | Launches **both** Antigravity IDE and Desktop Chat |

You can also customize your default launch preference globally by setting `MULTIGRAVITY_DEFAULT_LAUNCH` in your `~/.zshrc`:
```bash
export MULTIGRAVITY_DEFAULT_LAUNCH="both"   # Options: "ide" (default), "both", or "chat"
```

---

## 🛠️ Command Reference

| Command | Description |
|---|---|
| `multigravity new <name...> [options]` | Create one or more profiles and `.app` shortcuts (shared by default) |
| `multigravity new <name> --isolated` | Create a clean-slate, fully isolated profile (empty extensions & settings) |
| `multigravity new <name> --from <template>` | Create a profile based on a saved template |
| `multigravity <name> [flags]` | Launch the profile (IDE by default, `--chat`, `--both`, `--ide`) |
| `multigravity list` | List all existing profiles |
| `multigravity status` | Show running processes (App & IDE), storage size, and last modified date |
| `multigravity rename <old> <new>` | Rename a profile and update its macOS shortcut |
| `multigravity clone <src> <dest>` | Duplicate an existing profile and its configuration |
| `multigravity delete <name>` | Delete a profile and remove its desktop shortcut |
| `multigravity template save <profile> <name>` | Save an existing profile as a reusable template |
| `multigravity template list` | List all saved templates |
| `multigravity template delete <name>` | Delete a template |
| `multigravity export <name> [path]` | Export a profile to a compressed `.tar.gz` archive |
| `multigravity import <archive> [name]` | Import and restore a profile from a `.tar.gz` archive |
| `multigravity stats` | Show disk space usage breakdown across all profiles |
| `multigravity doctor` | Diagnose environment, binary paths, and keychain status |
| `multigravity completion` | Setup instructions for Zsh / Bash shell auto-completion |
| `multigravity update` | Update Multigravity to the latest version |

---

## ⚙️ Environment Variables

| Variable | Default | Description |
|---|---|---|
| `MULTIGRAVITY_DEFAULT_LAUNCH` | `ide` | Default launch mode: `ide` (default), `both`, or `chat` |
| `MULTIGRAVITY_HOME` | `~/AntigravityProfiles` | Base directory where all profile data is stored |
| `MULTIGRAVITY_AGY` | `/Applications/Antigravity.app` | Override path to Antigravity (desktop) app |
| `MULTIGRAVITY_IDE` | `/Applications/Antigravity IDE.app` | Override path to Antigravity IDE app |

---

## 📂 Profile Architecture

Each profile created in `~/AntigravityProfiles/<name>/` simulates an isolated user environment:

```
~/AntigravityProfiles/<name>/
├── .gemini/
│   ├── bin/                    → Symlink to ~/.gemini/bin (agy binary)
│   ├── config/
│   │   ├── mcp_config.json     → Symlink to shared MCP configuration
│   │   ├── plugins/            → Symlink to shared plugins
│   │   ├── skills/             → Symlink to shared skills
│   │   └── sidecars/           → Symlink to shared sidecars
│   ├── GEMINI.md               → Symlink to global instructions
│   └── trustedFolders.json     → Symlink to trusted folders list
├── .antigravity-ide/
│   └── extensions/             → Symlink to system extensions (shared by default)
├── bin/
│   └── security                # Transparent security shim isolating keychain calls
├── Library/
│   ├── Keychains/
│   │   ├── login.keychain-db   # Private, isolated macOS Keychain for this profile
│   │   └── login.keychain      → Symlink to login.keychain-db
│   └── Application Support/
│       ├── Antigravity/        # Desktop app session data, state, and browser storage
│       └── Antigravity IDE/    # IDE workspace state, history, and User settings
└── .zshenv                     # Profile shell environment (HOME, ZDOTDIR, PATH)
```

### How Credential Isolation Works
1. When Antigravity backend (`agy`) queries credentials, it invokes the `/usr/bin/security` tool for `service="gemini"` and `account="antigravity"`.
2. Multigravity places a transparent `security` shim in the profile's `PATH`.
3. The shim redirects credential lookups and saves to the profile's dedicated `login.keychain-db` without touching your system's global keychain.
4. `antigravity.serverArgs` is automatically configured with `--gemini_dir` in the profile's IDE settings, ensuring complete runtime separation.

---

## 🗑️ Uninstallation

To uninstall Multigravity:

```bash
./uninstall.sh
```

The uninstaller removes the binary and optionally prompts whether you want to delete your profile data in `~/AntigravityProfiles` and macOS shortcuts.

---

## 📄 License

MIT © [Kamil Bysiec](https://github.com/kbysiec)

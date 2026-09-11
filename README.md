# ChatGPT Workspace Setup

A small Windows utility that gives the ChatGPT desktop app a controlled local
workspace without moving the system-wide TEMP directory.

It configures two independent locations:

- a private `TEMP` / `TMP` directory inherited only by ChatGPT and its child processes;
- the `projectlessWorkspaceRoot` used for Work and Codex tasks without a project.

The default layout is:

```text
C:\CODE\
├── temp\
└── inbox\
```

Both paths remain editable. The installer creates missing directories and adds
separate Start menu entries for launching ChatGPT and reopening the settings.

## Highlights

- English installer and interface by default, with Polish available
- per-user installation; administrator rights are not required
- no changes to Windows system or user TEMP variables
- isolated, persistent `inbox` for projectless Work/Codex tasks
- settings can be changed later by running ChatGPT Workspace Setup again
- automatic backup before changing the ChatGPT configuration
- high-DPI-aware interface and a windowless launcher
- standard Windows uninstaller

## Installation

Download `ChatGPT-Workspace-Setup-1.1.6.exe` from the latest release and run it.
Close ChatGPT completely, including its tray process, before starting ChatGPT
through the new **ChatGPT Workspace** shortcut.

See [INSTALLATION.md](INSTALLATION.md) or [INSTALACJA.md](INSTALACJA.md) for details.

## Compatibility with ChatGPT updates

The launcher discovers the currently installed ChatGPT package on every start,
instead of storing its versioned installation path. Its own settings are kept in
`%LOCALAPPDATA%\Programs\ChatGPTFolderLauncher\folders.xml`, outside the ChatGPT
package, so normal Microsoft Store / ChatGPT updates should preserve them.

Compatibility cannot be guaranteed if a future ChatGPT release changes its
package identity, executable layout, or removes/renames the
`projectlessWorkspaceRoot` setting. Re-running this project's installer repairs
the launcher files and shortcuts but does not overwrite the selected folders.

## Build

The project uses the .NET Framework C# compiler included with Windows and Inno
Setup 7. Run `Build-Installer.ps1` to build the executables and installer.

## Scope

This project is an independent utility. It is not affiliated with or endorsed by
OpenAI. The ChatGPT name and icon belong to their respective owner.

## License

[MIT](LICENSE)

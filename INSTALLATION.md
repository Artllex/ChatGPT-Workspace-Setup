# Installation and folder changes

Run `ChatGPT-Workspace-Setup-1.2.3.exe`. English is selected by default; Polish remains available in the language selector.
Choose the root folder (default: `C:\CODE`). The installer derives `temp` and
`inbox`; both paths remain editable.

The installer works per user and does not require administrator rights. It adds
an uninstall entry to Windows Settings, Start menu shortcuts, and an optional
desktop shortcut. Run the same installer again or use **ChatGPT - folder settings**
to change the paths later.

Close ChatGPT completely, including its tray process, then start it through
**ChatGPT - folders**. The launcher sets TEMP/TMP only for ChatGPT and updates
the task folder setting. It does not change Windows environment variables.

Uninstall removes the launcher and its shortcuts. It preserves files and tasks
inside the selected TEMP and inbox folders and does not move existing tasks.

## Firefox download routing

The installer registers the local component used by **Download Router**. In the
add-on settings, ChatGPT always uses the configured
`TEMP\<conversation title>` layout. Use **Add website** to assign any other
domain to a local folder; the rule also applies to subdomains. The add-on needs
Mozilla signing before it can be installed permanently in standard Firefox.
Its language follows Firefox by default and can be overridden with English or
Polish in the settings. Access to all website addresses is required to match
downloads against routes; protected Firefox pages remain inaccessible.

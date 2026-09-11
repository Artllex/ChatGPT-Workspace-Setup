using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

static class WorkspaceLauncher {
    [STAThread]
    static void Main() {
        try {
            string directory = AppDomain.CurrentDomain.BaseDirectory;
            string script = Path.Combine(directory, "Start-ChatGPT.ps1");
            string powershell = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.Windows), "System32", "WindowsPowerShell", "v1.0", "powershell.exe");
            var info = new ProcessStartInfo {
                FileName = powershell,
                Arguments = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -WindowStyle Hidden -File \"" + script + "\"",
                WorkingDirectory = directory,
                UseShellExecute = false,
                CreateNoWindow = true,
                WindowStyle = ProcessWindowStyle.Hidden
            };
            Process.Start(info);
        } catch (Exception ex) {
            MessageBox.Show(ex.Message, "ChatGPT Workspace", MessageBoxButtons.OK, MessageBoxIcon.Warning);
        }
    }
}

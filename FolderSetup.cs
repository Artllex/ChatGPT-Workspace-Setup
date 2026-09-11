using System;
using System.IO;
using System.Drawing;
using System.Windows.Forms;
using System.Xml.Linq;
using System.Reflection;
using System.Globalization;
using System.Drawing.Drawing2D;

class RoundedButton : Button {
    public int Radius = 8;
    protected override void OnResize(EventArgs e) {
        base.OnResize(e);
        using(var path=new GraphicsPath()) {
            int d=Radius*2;
            path.AddArc(0,0,d,d,180,90); path.AddArc(Width-d-1,0,d,d,270,90);
            path.AddArc(Width-d-1,Height-d-1,d,d,0,90); path.AddArc(0,Height-d-1,d,d,90,90);
            path.CloseFigure(); Region=new Region(path);
        }
    }
}

class FolderSetup : Form {
    static string InstallDir = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "Programs", "ChatGPTFolderLauncher");
    static string DesktopDir = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
    TextBox root = new TextBox(), temp = new TextBox(), inbox = new TextBox();
    Label status = new Label();
    bool loading;
    static bool? PolishOverride;
    static bool Polish { get { return PolishOverride ?? (CultureInfo.CurrentUICulture.TwoLetterISOLanguageName == "pl"); } }
    static string T(string pl, string en) { return Polish ? pl : en; }
    static string Normalize(string value) {
        value = value.Trim();
        if (value.Length < 3 || !Char.IsLetter(value[0]) || value[1] != ':' || value[2] != '\\' || value.IndexOfAny(new char[]{'\'', '"', '\r', '\n', '*', '?'}) >= 0)
            throw new Exception(T("Wybierz pełną lokalną ścieżkę, np. C:\\CODE. Apostrofy i znaki specjalne nie są obsługiwane.", "Choose a full local path, e.g. C:\\CODE. Apostrophes and special characters are not supported."));
        return Path.GetFullPath(value).TrimEnd('\\') + (Path.GetFullPath(value).Length == 3 ? "\\" : "");
    }
    public FolderSetup() {
        Text = "ChatGPT Workspace Setup"; AutoScaleMode=AutoScaleMode.None;
        ClientSize = new Size(760, 520); Font = new Font("Segoe UI", 10); BackColor=Color.FromArgb(247,247,248);
        StartPosition = FormStartPosition.CenterScreen; FormBorderStyle = FormBorderStyle.FixedDialog; MaximizeBox = false;
        Stream iconStream=Assembly.GetExecutingAssembly().GetManifestResourceStream("AppIcon");
        if(iconStream!=null) using(iconStream) using(var sourceIcon=new Icon(iconStream,new Size(16,16))) {Icon=(Icon)sourceIcon.Clone();}
        var header=new Panel {Location=new Point(0,0),Size=new Size(760,92),BackColor=Color.FromArgb(32,33,35)}; Controls.Add(header);
        header.Controls.Add(new Label {Text="ChatGPT Workspace Setup",ForeColor=Color.White,BackColor=Color.Transparent,Location=new Point(30,20),Size=new Size(680,34),Font=new Font("Segoe UI",18,FontStyle.Bold)});
        header.Controls.Add(new Label {Text=T("Lokalne foldery pracy ChatGPT", "Local ChatGPT workspace folders"),ForeColor=Color.FromArgb(205,207,210),BackColor=Color.Transparent,Location=new Point(32,57),Size=new Size(660,24)});
        var help = new Label {Text=T("Wybierz katalog główny, a potem dostosuj ścieżki TEMP i zadań. Zmiana katalogu głównego ponownie wylicza obie ścieżki.", "Choose the root folder, then adjust the TEMP and task paths. Changing the root folder recalculates both paths."), Location=new Point(28,108), Size=new Size(704,44),ForeColor=Color.FromArgb(70,70,72)}; Controls.Add(help);
        Row(T("Katalog główny", "Root folder"),root,158); Row(T("Pliki tymczasowe ChatGPT (TEMP)", "ChatGPT temporary files (TEMP)"),temp,238); Row(T("Folder zadań bez projektu (inbox)", "Tasks without a project (inbox)"),inbox,318);
        root.TextChanged += delegate { if (!loading) { temp.Text=root.Text.TrimEnd('\\')+"\\temp"; inbox.Text=root.Text.TrimEnd('\\')+"\\inbox"; } };
        loading=true; root.Text="C:\\CODE"; temp.Text="C:\\CODE\\temp"; inbox.Text="C:\\CODE\\inbox";
        string settings=Path.Combine(InstallDir,"folders.xml");
        if(File.Exists(settings)) { var x=XDocument.Load(settings).Root; root.Text=(string)x.Element("Root"); temp.Text=(string)x.Element("Temp"); inbox.Text=(string)x.Element("Inbox"); }
        loading=false;
        status.Text=T("Ustawienia zaczną obowiązywać przy kolejnym uruchomieniu przez skrót ChatGPT Workspace.\nIstniejące pliki i zadania pozostaną w swoich folderach.", "Settings take effect on the next start through the ChatGPT Workspace shortcut.\nExisting files and tasks remain in their folders."); status.Location=new Point(28,402); status.Size=new Size(700,48); status.ForeColor=Color.FromArgb(70,70,72); Controls.Add(status);
        var save = new RoundedButton {Text=T("Zapisz ustawienia", "Save settings"), Location=new Point(470,466), Size=new Size(166,36),BackColor=Color.FromArgb(16,163,127),ForeColor=Color.White,FlatStyle=FlatStyle.Flat,Cursor=Cursors.Hand}; save.FlatAppearance.BorderSize=0; save.FlatAppearance.MouseOverBackColor=Color.FromArgb(13,148,115);
        save.Click += delegate { try { bool portable=Install(); MessageBox.Show(portable ? T("Zapisano ustawienia i utworzono skróty na pulpicie.\n\nZamknij ChatGPT, również w zasobniku, i użyj skrótu ChatGPT - foldery.", "Settings saved and desktop shortcuts created.\n\nClose ChatGPT, including its tray process, and use the ChatGPT - folders shortcut.") : T("Zapisano ustawienia. Zostaną zastosowane przy następnym uruchomieniu ChatGPT przez skrót programu.", "Settings saved. They will be applied the next time ChatGPT is started through the program shortcut."),Text); Close(); } catch(Exception ex) {MessageBox.Show(ex.Message,Text,MessageBoxButtons.OK,MessageBoxIcon.Error);} }; Controls.Add(save);
        var cancel=new RoundedButton {Text=T("Anuluj", "Cancel"), Location=new Point(646,466), Size=new Size(86,36),FlatStyle=FlatStyle.Flat,BackColor=Color.FromArgb(229,229,231),ForeColor=Color.FromArgb(32,33,35),Cursor=Cursors.Hand}; cancel.FlatAppearance.BorderSize=0; cancel.FlatAppearance.MouseOverBackColor=Color.FromArgb(215,215,218); cancel.Click+=delegate {Close();}; Controls.Add(cancel);
        using(var graphics=CreateGraphics()) {float factor=graphics.DpiX/96F; if(factor>1.01F) Scale(new SizeF(factor,factor));}
        Rectangle work=Screen.FromControl(this).WorkingArea;
        if(Width>work.Width-40 || Height>work.Height-40) {
            float fit=Math.Min((work.Width-40F)/Width,(work.Height-40F)/Height);
            if(fit<1F) Scale(new SizeF(fit,fit));
        }
        Shown+=delegate {WindowState=FormWindowState.Normal; Activate(); BringToFront();};
    }
    void Row(string label, TextBox box, int y) {
        Controls.Add(new Label {Text=label,Location=new Point(28,y),Size=new Size(680,24),Font=new Font("Segoe UI",10,FontStyle.Bold)});
        box.Location=new Point(28,y+27); box.Size=new Size(590,28); box.BorderStyle=BorderStyle.FixedSingle; Controls.Add(box);
        var browse=new RoundedButton {Text=T("Wybierz…", "Browse…"),Location=new Point(630,y+25),Size=new Size(102,32),FlatStyle=FlatStyle.Flat,BackColor=Color.FromArgb(229,229,231),ForeColor=Color.FromArgb(32,33,35),Cursor=Cursors.Hand}; browse.FlatAppearance.BorderSize=0; browse.FlatAppearance.MouseOverBackColor=Color.FromArgb(215,215,218);
        browse.Click+=delegate {using(var dialog=new FolderBrowserDialog()) {dialog.Description=label; if(Directory.Exists(box.Text)) dialog.SelectedPath=box.Text; if(dialog.ShowDialog()==DialogResult.OK) box.Text=dialog.SelectedPath;}}; Controls.Add(browse);
    }
    static void AtomicWrite(string file,string text) {
        string stage=file+"."+Guid.NewGuid().ToString("N")+".tmp"; File.WriteAllText(stage,text,new System.Text.UTF8Encoding(false));
        if(File.Exists(file)) File.Replace(stage,file,file+".previous"); else File.Move(stage,file);
    }
    static void Shortcut(string path,string target,string args,string working) {
        dynamic shell=Activator.CreateInstance(Type.GetTypeFromProgID("WScript.Shell"));
        dynamic link=shell.CreateShortcut(path); link.TargetPath=target; link.Arguments=args; link.WorkingDirectory=working; link.Save();
    }
    bool Install() {
        string r=Normalize(root.Text), t=Normalize(temp.Text), i=Normalize(inbox.Text);
        if(String.Equals(t,i,StringComparison.OrdinalIgnoreCase)) throw new Exception(T("TEMP i inbox muszą mieć różne ścieżki.", "TEMP and inbox must use different paths."));
        if(t.Length==3 || i.Length==3) throw new Exception(T("TEMP i inbox muszą być podfolderami, nie katalogiem głównym dysku.", "TEMP and inbox must be subfolders, not a drive root."));
        foreach(string folder in new[]{r,t,i,InstallDir}) Directory.CreateDirectory(folder);
        foreach(string folder in new[]{t,i}) {string probe=Path.Combine(folder,".chatgpt-write-test-"+Guid.NewGuid().ToString("N")); File.WriteAllText(probe,""); File.Delete(probe);}
        string exe=Path.Combine(InstallDir,"ChatGPT-Workspace-Setup.exe");
        bool portable=!String.Equals(Application.ExecutablePath,exe,StringComparison.OrdinalIgnoreCase);
        if(portable) File.Copy(Application.ExecutablePath,exe,true);
        if(portable) using(var stream=Assembly.GetExecutingAssembly().GetManifestResourceStream("Launcher")) using(var reader=new StreamReader(stream)) AtomicWrite(Path.Combine(InstallDir,"Start-ChatGPT.ps1"),reader.ReadToEnd());
        string language=Polish ? "polish" : "english";
        string existing=Path.Combine(InstallDir,"folders.xml");
        if(File.Exists(existing)) {var languageElement=XDocument.Load(existing).Root.Element("Language"); if(languageElement!=null) language=(string)languageElement;}
        var doc=new XDocument(new XElement("Folders",new XElement("Root",r),new XElement("Temp",t),new XElement("Inbox",i),new XElement("Language",language)));
        AtomicWrite(Path.Combine(InstallDir,"folders.xml"),doc.ToString());
        if(portable) {
            string desktop=DesktopDir;
            string launcher=Path.Combine(InstallDir,"ChatGPT-Workspace.exe");
            File.Copy(Path.Combine(Path.GetDirectoryName(Application.ExecutablePath),"ChatGPT-Workspace.exe"),launcher,true);
            Shortcut(Path.Combine(desktop,T("ChatGPT - foldery.lnk", "ChatGPT - folders.lnk")),launcher,"",InstallDir);
            Shortcut(Path.Combine(desktop,T("ChatGPT - ustawienia folderów.lnk", "ChatGPT - folder settings.lnk")),exe,"",InstallDir);
        }
        return portable;
    }
    [STAThread] static void Main(string[] args) {
        string languageFile=Path.Combine(InstallDir,"folders.xml");
        if(File.Exists(languageFile)) {try {string language=(string)XDocument.Load(languageFile).Root.Element("Language"); if(language=="english") PolishOverride=false; else if(language=="polish") PolishOverride=true;} catch {}}
        Application.EnableVisualStyles(); Application.SetCompatibleTextRenderingDefault(false);
        try {
            if(args.Length>0 && args[0]=="--self-test") {
                InstallDir=Path.Combine(args[2],"installed"); DesktopDir=Path.Combine(args[2],"desktop"); Directory.CreateDirectory(DesktopDir);
                if(Normalize("C:\\CODE")!="C:\\CODE" || Normalize("C:\\")!="C:\\") throw new Exception("Path test failed");
                bool rejected=false; try {Normalize("relative");} catch {rejected=true;} if(!rejected) throw new Exception("Relative path accepted");
                using(var f=new FolderSetup()) {f.root.Text="D:\\Moje projekty"; if(f.temp.Text!="D:\\Moje projekty\\temp" || f.inbox.Text!="D:\\Moje projekty\\inbox") throw new Exception("Defaults failed"); f.temp.Text="E:\\Scratch"; if(f.inbox.Text!="D:\\Moje projekty\\inbox") throw new Exception("Manual override failed");
                    f.root.Text=Path.Combine(args[2],"root"); f.temp.Text=Path.Combine(args[2],"custom-temp"); f.Install();
                    using(var again=new FolderSetup()) {if(again.temp.Text!=f.temp.Text || again.inbox.Text!=f.inbox.Text) throw new Exception("Reload failed"); again.inbox.Text=Path.Combine(args[2],"new-inbox"); again.Install();}
                    var saved=XDocument.Load(Path.Combine(InstallDir,"folders.xml")); if((string)saved.Root.Element("Inbox")!=Path.Combine(args[2],"new-inbox")) throw new Exception("Reconfiguration failed");
                    f.root.Text="C:\\CODE"; f.ShowInTaskbar=false; f.StartPosition=FormStartPosition.Manual; f.Location=new Point(-2500,-2500); f.Show(); Application.DoEvents();
                    using(var bmp=new Bitmap(f.Width,f.Height)) { f.DrawToBitmap(bmp,new Rectangle(0,0,f.Width,f.Height)); bmp.Save(args[1]); } f.Hide();
                }
                return;
            }
            Application.Run(new FolderSetup());
        } catch(Exception ex) {if(args.Length>0) throw; MessageBox.Show(ex.Message,"ChatGPT Workspace Setup");}
    }
}

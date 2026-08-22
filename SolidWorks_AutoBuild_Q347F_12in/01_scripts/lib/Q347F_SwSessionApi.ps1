function Add-EmbeddedSwSessionApiType {
    if ('Q347F.SwSessionApi' -as [type]) { return }

    $source = @'
using Sys = System;
using IO = System.IO;
using Interop = System.Runtime.InteropServices;
using SW = SolidWorks.Interop.sldworks;
using SWC = SolidWorks.Interop.swconst;

namespace Q347F
{
    public sealed class SwSession
    {
        public SW.SldWorks App;
        public string Mode;
        public string Revision;
        public int ProcessId;
        public bool Visible;
        public int LatestFileVersion;
    }

    public static class SwSessionApi
    {
        private static SwSession BuildSession(SW.SldWorks app, string mode)
        {
            if (app == null) throw new Sys.InvalidOperationException("SOLIDWORKS application object is null.");
            app.Visible = true;
            SwSession session = new SwSession
            {
                App = app,
                Mode = mode,
                Revision = app.RevisionNumber(),
                ProcessId = app.GetProcessID(),
                Visible = app.Visible,
                LatestFileVersion = app.GetLatestSupportedFileVersion()
            };
            if (Sys.String.Equals(mode, "START_NEW_ISOLATED", Sys.StringComparison.OrdinalIgnoreCase))
                Sys.Environment.SetEnvironmentVariable("Q347F_ISOLATED_SW_PID", session.ProcessId.ToString());
            return session;
        }

        private static int TryGetActiveProcessId()
        {
            try
            {
                object active = Interop.Marshal.GetActiveObject("SldWorks.Application");
                SW.SldWorks app = active as SW.SldWorks;
                return app == null ? 0 : app.GetProcessID();
            }
            catch { return 0; }
        }

        public static SwSession StartNewIsolated()
        {
            int previousPid = TryGetActiveProcessId();
            Sys.Type t = Sys.Type.GetTypeFromProgID("SldWorks.Application", true);
            object obj = Sys.Activator.CreateInstance(t);
            SW.SldWorks app = (SW.SldWorks)obj;
            int newPid = 0;
            try { newPid = app.GetProcessID(); } catch { }
            string mode = (previousPid > 0 && newPid == previousPid) ? "START_NEW_REUSED_ACTIVE" : "START_NEW_ISOLATED";
            return BuildSession(app, mode);
        }

        public static SwSession ConnectOrStart()
        {
            string forceIsolated = Sys.Environment.GetEnvironmentVariable("Q347F_FORCE_ISOLATED_SW");
            if (Sys.String.Equals(forceIsolated, "1", Sys.StringComparison.OrdinalIgnoreCase) ||
                Sys.String.Equals(forceIsolated, "true", Sys.StringComparison.OrdinalIgnoreCase))
                return StartNewIsolated();

            object obj = null;
            string mode = "";
            try
            {
                obj = Interop.Marshal.GetActiveObject("SldWorks.Application");
                mode = "ATTACH";
            }
            catch
            {
                Sys.Type t = Sys.Type.GetTypeFromProgID("SldWorks.Application", true);
                obj = Sys.Activator.CreateInstance(t);
                mode = "START_NEW";
            }
            return BuildSession((SW.SldWorks)obj, mode);
        }

        public static void ExitIsolated(SwSession session)
        {
            if (session == null || session.App == null) return;
            if (!Sys.String.Equals(session.Mode, "START_NEW_ISOLATED", Sys.StringComparison.OrdinalIgnoreCase)) return;
            try { session.App.ExitApp(); } catch { }
            Sys.Environment.SetEnvironmentVariable("Q347F_ISOLATED_SW_PID", null);
        }

        public static string GetDefaultPartTemplate(SwSession session)
        {
            if (session == null || session.App == null)
                throw new Sys.ArgumentNullException("session", "SOLIDWORKS session is null.");
            return session.App.GetUserPreferenceStringValue((int)SWC.swUserPreferenceStringValue_e.swDefaultTemplatePart);
        }

        public static object NewPart(SwSession session, string templatePath)
        {
            if (session == null || session.App == null)
                throw new Sys.ArgumentNullException("session", "SOLIDWORKS session is null.");
            object doc = session.App.NewDocument(templatePath, 0, 0.0, 0.0);
            if (doc == null) throw new Sys.InvalidOperationException("ISldWorks.NewDocument returned null.");
            SW.ModelDoc2 model = (SW.ModelDoc2)doc;
            model.ShowFeatureErrorDialog = false;
            return doc;
        }

        public static bool CloseDocumentByPath(SwSession session, string fullPath)
        {
            if (session == null || session.App == null || Sys.String.IsNullOrWhiteSpace(fullPath)) return false;
            string target;
            try { target = IO.Path.GetFullPath(fullPath); } catch { target = fullPath; }
            SW.ModelDoc2 doc = FindOpenDocumentByPathOrTitle(session.App, target);
            if (doc == null) return false;
            string title = doc.GetTitle();
            session.App.CloseDoc(title);
            return true;
        }

        public static SW.ModelDoc2 FindOpenDocumentByPathOrTitle(SW.SldWorks app, string fullPath)
        {
            if (app == null || Sys.String.IsNullOrWhiteSpace(fullPath)) return null;
            string target;
            try { target = IO.Path.GetFullPath(fullPath); } catch { target = fullPath; }
            string targetTitle = IO.Path.GetFileName(target);
            try
            {
                SW.ModelDoc2 exact = app.GetOpenDocumentByName(target) as SW.ModelDoc2;
                if (exact != null) return exact;
            }
            catch { }
            try
            {
                SW.ModelDoc2 cur = app.GetFirstDocument() as SW.ModelDoc2;
                int guard = 0;
                while (cur != null && guard++ < 500)
                {
                    string p = "";
                    string title = "";
                    try { p = cur.GetPathName(); } catch { }
                    try { title = cur.GetTitle(); } catch { }
                    if (!Sys.String.IsNullOrWhiteSpace(p))
                    {
                        string normalized;
                        try { normalized = IO.Path.GetFullPath(p); } catch { normalized = p; }
                        if (Sys.String.Equals(normalized, target, Sys.StringComparison.OrdinalIgnoreCase)) return cur;
                    }
                    if (!Sys.String.IsNullOrWhiteSpace(title) &&
                        Sys.String.Equals(title, targetTitle, Sys.StringComparison.OrdinalIgnoreCase)) return cur;
                    try { cur = cur.GetNext() as SW.ModelDoc2; } catch { cur = null; }
                }
            }
            catch { }
            return null;
        }

        public static void CloseDocument(SwSession session, object modelObject)
        {
            if (session == null || session.App == null || modelObject == null) return;
            SW.ModelDoc2 model = (SW.ModelDoc2)modelObject;
            try { session.App.CloseDoc(model.GetTitle()); } catch { }
        }
    }
}
'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

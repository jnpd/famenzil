function Add-EmbeddedSwSessionApiType {
    if ('Q347F.SwSessionApi' -as [type]) { return }

    $source = @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

namespace Q347F
{
    public sealed class SwSession
    {
        public SldWorks App;
        public string Mode;
        public string Revision;
        public int ProcessId;
        public bool Visible;
        public int LatestFileVersion;
    }

    public static class SwSessionApi
    {
        private static SwSession BuildSession(SldWorks app, string mode)
        {
            if (app == null) throw new InvalidOperationException("SOLIDWORKS application object is null.");
            app.Visible = true;
            return new SwSession
            {
                App = app,
                Mode = mode,
                Revision = app.RevisionNumber(),
                ProcessId = app.GetProcessID(),
                Visible = app.Visible,
                LatestFileVersion = app.GetLatestSupportedFileVersion()
            };
        }

        public static SwSession StartNewIsolated()
        {
            Type t = Type.GetTypeFromProgID("SldWorks.Application", true);
            object obj = Activator.CreateInstance(t);
            return BuildSession((SldWorks)obj, "START_NEW_ISOLATED");
        }

        public static SwSession ConnectOrStart()
        {
            string forceIsolated = Environment.GetEnvironmentVariable("Q347F_FORCE_ISOLATED_SW");
            if (String.Equals(forceIsolated, "1", StringComparison.OrdinalIgnoreCase) ||
                String.Equals(forceIsolated, "true", StringComparison.OrdinalIgnoreCase))
            {
                return StartNewIsolated();
            }

            object obj = null;
            string mode = "";
            try
            {
                obj = Marshal.GetActiveObject("SldWorks.Application");
                mode = "ATTACH";
            }
            catch
            {
                Type t = Type.GetTypeFromProgID("SldWorks.Application", true);
                obj = Activator.CreateInstance(t);
                mode = "START_NEW";
            }

            return BuildSession((SldWorks)obj, mode);
        }

        public static void ExitIsolated(SwSession session)
        {
            if (session == null || session.App == null) return;
            if (!String.Equals(session.Mode, "START_NEW_ISOLATED", StringComparison.OrdinalIgnoreCase)) return;
            try { session.App.ExitApp(); } catch { }
        }

        public static string GetDefaultPartTemplate(SwSession session)
        {
            if (session == null || session.App == null)
                throw new ArgumentNullException("session", "SOLIDWORKS session is null.");
            return session.App.GetUserPreferenceStringValue((int)swUserPreferenceStringValue_e.swDefaultTemplatePart);
        }

        public static object NewPart(SwSession session, string templatePath)
        {
            if (session == null || session.App == null)
                throw new ArgumentNullException("session", "SOLIDWORKS session is null.");
            object doc = session.App.NewDocument(templatePath, 0, 0.0, 0.0);
            if (doc == null) throw new InvalidOperationException("ISldWorks.NewDocument returned null.");
            ModelDoc2 model = (ModelDoc2)doc;
            model.ShowFeatureErrorDialog = false;
            return doc;
        }

        public static bool CloseDocumentByPath(SwSession session, string fullPath)
        {
            if (session == null || session.App == null || String.IsNullOrWhiteSpace(fullPath)) return false;

            string target;
            try { target = Path.GetFullPath(fullPath); }
            catch { target = fullPath; }

            ModelDoc2 doc = null;
            try { doc = session.App.GetOpenDocumentByName(target) as ModelDoc2; } catch { }

            if (doc == null)
            {
                try
                {
                    ModelDoc2 cur = session.App.GetFirstDocument() as ModelDoc2;
                    while (cur != null)
                    {
                        string p = "";
                        try { p = cur.GetPathName(); } catch { }
                        if (!String.IsNullOrWhiteSpace(p))
                        {
                            string normalized;
                            try { normalized = Path.GetFullPath(p); } catch { normalized = p; }
                            if (String.Equals(normalized, target, StringComparison.OrdinalIgnoreCase))
                            {
                                doc = cur;
                                break;
                            }
                        }
                        try { cur = cur.GetNext() as ModelDoc2; } catch { cur = null; }
                    }
                }
                catch { }
            }

            if (doc == null) return false;

            string title = doc.GetTitle();
            session.App.CloseDoc(title);
            return true;
        }

        public static void CloseDocument(SwSession session, object modelObject)
        {
            if (session == null || session.App == null || modelObject == null) return;
            ModelDoc2 model = (ModelDoc2)modelObject;
            try { session.App.CloseDoc(model.GetTitle()); } catch { }
        }
    }
}

'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

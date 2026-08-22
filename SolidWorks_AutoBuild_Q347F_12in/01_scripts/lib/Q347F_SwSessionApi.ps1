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
        public static SwSession ConnectOrStart()
        {
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

            SldWorks app = (SldWorks)obj;
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

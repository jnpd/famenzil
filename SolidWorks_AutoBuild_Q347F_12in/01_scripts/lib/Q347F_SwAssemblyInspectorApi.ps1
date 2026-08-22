function Add-EmbeddedSwAssemblyInspectorApiType {
    if ('Q347F.SwAssemblyInspectorApi' -as [type]) { return }

    $source = @'
using Sys = System;
using IO = System.IO;
using Collections = System.Collections.Generic;
using SW = SolidWorks.Interop.sldworks;
using SWC = SolidWorks.Interop.swconst;

namespace Q347F
{
    public sealed class RefComponentInfo
    {
        public int Order;
        public int Level;
        public string Name;
        public string ParentName;
        public string Path;
        public string ReferencedConfiguration;
        public int DocumentType;
        public int SuppressionState;
        public bool Hidden;
        public bool Fixed;
        public bool MissingReference;
        public double[] Transform;
        public double TxMm;
        public double TyMm;
        public double TzMm;
    }

    public sealed class RefMateEntityInfo
    {
        public int Index;
        public string ComponentName;
        public string ComponentPath;
        public int ReferenceType;
        public double[] EntityParams;
    }

    public sealed class AsmDimensionInfo
    {
        public string Name;
        public string FullName;
        public double SystemValue;
        public double ApproxMm;
        public string FeatureName;
    }

    public sealed class RefMateInfo
    {
        public int Order;
        public string AssemblyPath;
        public string Name;
        public string TypeName;
        public bool Suppressed;
        public int Alignment;
        public Collections.List<RefMateEntityInfo> Entities = new Collections.List<RefMateEntityInfo>();
        public Collections.List<AsmDimensionInfo> Dimensions = new Collections.List<AsmDimensionInfo>();
    }

    public sealed class RefAssemblyReport
    {
        public string Path;
        public string Title;
        public string ActiveConfiguration;
        public string Revision;
        public int OpenErrors;
        public int OpenWarnings;
        public int ComponentCount;
        public int LightweightComponentCount;
        public int MissingReferenceCount;
        public int MateCount;
        public Collections.List<RefComponentInfo> Components = new Collections.List<RefComponentInfo>();
        public Collections.List<RefMateInfo> Mates = new Collections.List<RefMateInfo>();
    }

    public static class SwAssemblyInspectorApi
    {
        private static SW.Feature FirstSubFeature(SW.Feature feature)
        {
            if (feature == null) return null;
            try { return feature.GetFirstSubFeature() as SW.Feature; } catch { return null; }
        }

        private static SW.Feature NextSubFeature(SW.Feature feature)
        {
            if (feature == null) return null;
            try { return feature.GetNextSubFeature() as SW.Feature; } catch { return null; }
        }

        private static SW.Feature NextFeature(SW.Feature feature)
        {
            if (feature == null) return null;
            try { return feature.GetNextFeature() as SW.Feature; } catch { return null; }
        }

        private static SW.ModelDoc2 FindOpenDocumentByPathOrTitle(SW.SldWorks app, string fullPath)
        {
            if (app == null || Sys.String.IsNullOrWhiteSpace(fullPath)) return null;
            string target;
            try { target = IO.Path.GetFullPath(fullPath); } catch { target = fullPath; }
            string titleWanted = IO.Path.GetFileName(target);

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
                    string path = "";
                    string title = "";
                    try { path = cur.GetPathName(); } catch { }
                    try { title = cur.GetTitle(); } catch { }
                    if (!Sys.String.IsNullOrWhiteSpace(path))
                    {
                        string normalized;
                        try { normalized = IO.Path.GetFullPath(path); } catch { normalized = path; }
                        if (Sys.String.Equals(normalized, target, Sys.StringComparison.OrdinalIgnoreCase)) return cur;
                    }
                    if (!Sys.String.IsNullOrWhiteSpace(title) &&
                        Sys.String.Equals(title, titleWanted, Sys.StringComparison.OrdinalIgnoreCase)) return cur;
                    try { cur = cur.GetNext() as SW.ModelDoc2; } catch { cur = null; }
                }
            }
            catch { }
            return null;
        }

        private static double[] ToDoubleArray(object raw)
        {
            Sys.Array a = raw as Sys.Array;
            if (a == null) return new double[0];
            double[] result = new double[a.Length];
            for (int i = 0; i < a.Length; i++)
            {
                try { result[i] = Sys.Convert.ToDouble(a.GetValue(i)); }
                catch { result[i] = 0.0; }
            }
            return result;
        }

        private static string ParentFromName(string name)
        {
            if (Sys.String.IsNullOrWhiteSpace(name)) return "";
            int p = name.LastIndexOf('/');
            return p <= 0 ? "" : name.Substring(0, p);
        }

        private static int LevelFromName(string name)
        {
            if (Sys.String.IsNullOrWhiteSpace(name)) return 0;
            int level = 0;
            foreach (char ch in name) if (ch == '/') level++;
            return level;
        }

        private static int DocumentTypeFromPath(string path)
        {
            string ext = "";
            try { ext = IO.Path.GetExtension(path) ?? ""; } catch { }
            if (ext.Equals(".SLDPRT", Sys.StringComparison.OrdinalIgnoreCase)) return (int)SWC.swDocumentTypes_e.swDocPART;
            if (ext.Equals(".SLDASM", Sys.StringComparison.OrdinalIgnoreCase)) return (int)SWC.swDocumentTypes_e.swDocASSEMBLY;
            if (ext.Equals(".SLDDRW", Sys.StringComparison.OrdinalIgnoreCase)) return (int)SWC.swDocumentTypes_e.swDocDRAWING;
            return 0;
        }

        private static string ResolveComponentPath(string rawPath, string assemblyDir)
        {
            if (Sys.String.IsNullOrWhiteSpace(rawPath)) return "";
            try
            {
                if (IO.File.Exists(rawPath)) return IO.Path.GetFullPath(rawPath);
                string file = IO.Path.GetFileName(rawPath);
                if (!Sys.String.IsNullOrWhiteSpace(file) && !Sys.String.IsNullOrWhiteSpace(assemblyDir))
                {
                    string local = IO.Path.Combine(assemblyDir, file);
                    if (IO.File.Exists(local)) return IO.Path.GetFullPath(local);
                }
            }
            catch { }
            return rawPath;
        }

        private static void CollectFeatureDimensions(SW.Feature f, Collections.List<AsmDimensionInfo> dims)
        {
            object current = null;
            try { current = f.GetFirstDisplayDimension(); } catch { return; }
            int guard = 0;
            while (current != null && guard++ < 100)
            {
                try
                {
                    SW.DisplayDimension dd = current as SW.DisplayDimension;
                    if (dd != null)
                    {
                        SW.Dimension d = dd.GetDimension2(0);
                        if (d != null)
                        {
                            double v = d.SystemValue;
                            dims.Add(new AsmDimensionInfo
                            {
                                Name = d.Name,
                                FullName = d.FullName,
                                SystemValue = v,
                                ApproxMm = v * 1000.0,
                                FeatureName = f.Name
                            });
                        }
                    }
                }
                catch { }
                try { current = f.GetNextDisplayDimension(current); } catch { break; }
            }
        }

        private static void CollectComponents(SW.AssemblyDoc assy, string assemblyDir, RefAssemblyReport report)
        {
            Sys.Array components = assy.GetComponents(false) as Sys.Array;
            if (components == null) return;
            int order = 0;
            foreach (object o in components)
            {
                SW.Component2 c = o as SW.Component2;
                if (c == null) continue;
                RefComponentInfo ci = new RefComponentInfo();
                ci.Order = ++order;
                try { ci.Name = c.Name2; } catch { ci.Name = ""; }
                ci.ParentName = ParentFromName(ci.Name);
                ci.Level = LevelFromName(ci.Name);
                string rawPath = "";
                try { rawPath = c.GetPathName(); } catch { }
                ci.Path = ResolveComponentPath(rawPath, assemblyDir);
                try { ci.ReferencedConfiguration = c.ReferencedConfiguration; } catch { ci.ReferencedConfiguration = ""; }
                ci.DocumentType = DocumentTypeFromPath(ci.Path);
                try { ci.SuppressionState = c.GetSuppression(); } catch { ci.SuppressionState = -1; }
                try { ci.Hidden = c.IsHidden(true); } catch { ci.Hidden = false; }
                try { ci.Fixed = c.IsFixed(); } catch { ci.Fixed = false; }
                ci.MissingReference = !Sys.String.IsNullOrWhiteSpace(ci.Path) && !IO.File.Exists(ci.Path);
                if (ci.MissingReference) report.MissingReferenceCount++;

                ci.Transform = new double[0];
                try
                {
                    SW.MathTransform t = c.Transform2;
                    if (t != null)
                    {
                        ci.Transform = ToDoubleArray(t.ArrayData);
                        if (ci.Transform.Length >= 12)
                        {
                            ci.TxMm = ci.Transform[9] * 1000.0;
                            ci.TyMm = ci.Transform[10] * 1000.0;
                            ci.TzMm = ci.Transform[11] * 1000.0;
                        }
                    }
                }
                catch { }
                report.Components.Add(ci);
            }
            report.ComponentCount = report.Components.Count;
        }

        private static void CollectMateFeature(SW.Feature mateFeature, string assemblyPath, RefAssemblyReport report, ref int order)
        {
            if (mateFeature == null) return;
            string typeName = "";
            try { typeName = mateFeature.GetTypeName2(); } catch { }
            if (Sys.String.IsNullOrWhiteSpace(typeName) || !typeName.StartsWith("Mate", Sys.StringComparison.OrdinalIgnoreCase)) return;

            RefMateInfo mi = new RefMateInfo();
            mi.Order = ++order;
            mi.AssemblyPath = assemblyPath;
            try { mi.Name = mateFeature.Name; } catch { mi.Name = ""; }
            mi.TypeName = typeName;
            try { mi.Suppressed = mateFeature.IsSuppressed(); } catch { mi.Suppressed = false; }
            CollectFeatureDimensions(mateFeature, mi.Dimensions);

            try
            {
                SW.Mate2 mate = mateFeature.GetSpecificFeature2() as SW.Mate2;
                if (mate != null)
                {
                    try { mi.Alignment = mate.Alignment; } catch { mi.Alignment = 0; }
                    int n = 0;
                    try { n = mate.GetMateEntityCount(); } catch { n = 0; }
                    for (int i = 0; i < n; i++)
                    {
                        try
                        {
                            SW.MateEntity2 e = mate.MateEntity(i) as SW.MateEntity2;
                            if (e == null) continue;
                            RefMateEntityInfo ei = new RefMateEntityInfo();
                            ei.Index = i;
                            try { ei.ReferenceType = e.ReferenceType2; } catch { ei.ReferenceType = 0; }
                            try { ei.EntityParams = ToDoubleArray(e.EntityParams); } catch { ei.EntityParams = new double[0]; }
                            try
                            {
                                SW.Component2 rc = e.ReferenceComponent as SW.Component2;
                                if (rc != null)
                                {
                                    try { ei.ComponentName = rc.Name2; } catch { ei.ComponentName = ""; }
                                    try { ei.ComponentPath = rc.GetPathName(); } catch { ei.ComponentPath = ""; }
                                }
                            }
                            catch { }
                            mi.Entities.Add(ei);
                        }
                        catch { }
                    }
                }
            }
            catch { }
            report.Mates.Add(mi);
        }

        private static void CollectMates(SW.ModelDoc2 model, string assemblyPath, RefAssemblyReport report)
        {
            int order = 0;
            SW.Feature f = null;
            try { f = model.FirstFeature() as SW.Feature; } catch { }
            int guard = 0;
            while (f != null && guard++ < 5000)
            {
                string type = "";
                try { type = f.GetTypeName2(); } catch { }
                if (Sys.String.Equals(type, "MateGroup", Sys.StringComparison.OrdinalIgnoreCase))
                {
                    SW.Feature sub = FirstSubFeature(f);
                    int subGuard = 0;
                    while (sub != null && subGuard++ < 5000)
                    {
                        CollectMateFeature(sub, assemblyPath, report, ref order);
                        sub = NextSubFeature(sub);
                    }
                }
                f = NextFeature(f);
            }
            report.MateCount = report.Mates.Count;
        }

        public static RefAssemblyReport Inspect(object appObject, string revision, string assemblyPath)
        {
            SW.SldWorks app = appObject as SW.SldWorks;
            if (app == null) throw new Sys.ArgumentException("appObject is not a SOLIDWORKS SldWorks application.");
            if (Sys.String.IsNullOrWhiteSpace(assemblyPath) || !IO.File.Exists(assemblyPath))
                throw new IO.FileNotFoundException("Reference SLDASM not found", assemblyPath);

            string fullPath = IO.Path.GetFullPath(assemblyPath);
            string workingDir = IO.Path.GetDirectoryName(fullPath);
            if (!Sys.String.IsNullOrWhiteSpace(workingDir)) { try { app.SetCurrentWorkingDirectory(workingDir); } catch { } }

            int errors = 0;
            int warnings = 0;
            SW.ModelDoc2 model = FindOpenDocumentByPathOrTitle(app, fullPath);
            bool openedHere = false;
            if (model == null)
            {
                int openOptions =
                    (int)SWC.swOpenDocOptions_e.swOpenDocOptions_Silent |
                    (int)SWC.swOpenDocOptions_e.swOpenDocOptions_ReadOnly |
                    (int)SWC.swOpenDocOptions_e.swOpenDocOptions_OverrideDefaultLoadLightweight |
                    (int)SWC.swOpenDocOptions_e.swOpenDocOptions_LoadLightweight;
                object opened = app.OpenDoc6(fullPath, (int)SWC.swDocumentTypes_e.swDocASSEMBLY, openOptions, "", ref errors, ref warnings);
                model = opened as SW.ModelDoc2;
                openedHere = model != null;
                if (model == null && errors == 65536)
                {
                    model = FindOpenDocumentByPathOrTitle(app, fullPath);
                    openedHere = false;
                }
            }
            if (model == null)
                throw new Sys.InvalidOperationException("SOLIDWORKS could not open reference assembly. OpenErrors=" + errors + ", OpenWarnings=" + warnings + ", Path=" + fullPath);

            try
            {
                SW.AssemblyDoc assy = model as SW.AssemblyDoc;
                if (assy == null) throw new Sys.InvalidOperationException("Opened document is not an AssemblyDoc.");
                RefAssemblyReport report = new RefAssemblyReport();
                report.Path = fullPath;
                report.Title = model.GetTitle();
                report.Revision = revision ?? "";
                report.OpenErrors = errors;
                report.OpenWarnings = warnings;
                try { report.ActiveConfiguration = model.ConfigurationManager.ActiveConfiguration.Name; } catch { report.ActiveConfiguration = ""; }
                try { report.LightweightComponentCount = assy.GetLightWeightComponentCount(); } catch { report.LightweightComponentCount = -1; }
                CollectComponents(assy, workingDir, report);
                CollectMates(model, report.Path, report);
                return report;
            }
            finally
            {
                if (openedHere && model != null) { try { app.CloseDoc(model.GetTitle()); } catch { } }
            }
        }
    }
}
'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

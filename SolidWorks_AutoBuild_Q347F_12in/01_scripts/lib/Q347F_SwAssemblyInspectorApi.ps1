function Add-EmbeddedSwAssemblyInspectorApiType {
    if ('Q347F.SwAssemblyInspectorApi' -as [type]) { return }

    $source = @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

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
        public List<RefMateEntityInfo> Entities = new List<RefMateEntityInfo>();
        public List<AsmDimensionInfo> Dimensions = new List<AsmDimensionInfo>();
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
        public List<RefComponentInfo> Components = new List<RefComponentInfo>();
        public List<RefMateInfo> Mates = new List<RefMateInfo>();
    }

    public static class SwAssemblyInspectorApi
    {
        private static SldWorks GetSessionApp(object sessionObject)
        {
            if (sessionObject == null) throw new ArgumentNullException("sessionObject");
            FieldInfo f = sessionObject.GetType().GetField("App");
            if (f == null) throw new InvalidOperationException("Session object has no public App field.");
            SldWorks app = f.GetValue(sessionObject) as SldWorks;
            if (app == null) throw new InvalidOperationException("Session App is not a SOLIDWORKS application object.");
            return app;
        }

        private static string GetSessionRevision(object sessionObject)
        {
            try
            {
                FieldInfo f = sessionObject.GetType().GetField("Revision");
                object v = f == null ? null : f.GetValue(sessionObject);
                return v == null ? "" : Convert.ToString(v);
            }
            catch { return ""; }
        }

        private static Feature FirstSubFeature(Feature feature)
        {
            if (feature == null) return null;
            try { return feature.GetFirstSubFeature() as Feature; }
            catch { return null; }
        }

        private static Feature NextSubFeature(Feature feature)
        {
            if (feature == null) return null;
            try { return feature.GetNextSubFeature() as Feature; }
            catch { return null; }
        }

        private static Feature NextFeature(Feature feature)
        {
            if (feature == null) return null;
            try { return feature.GetNextFeature() as Feature; }
            catch { return null; }
        }

        private static double[] ToDoubleArray(object raw)
        {
            Array a = raw as Array;
            if (a == null) return new double[0];
            double[] result = new double[a.Length];
            for (int i = 0; i < a.Length; i++)
            {
                try { result[i] = Convert.ToDouble(a.GetValue(i)); }
                catch { result[i] = 0.0; }
            }
            return result;
        }

        private static string ParentFromName(string name)
        {
            if (String.IsNullOrWhiteSpace(name)) return "";
            int p = name.LastIndexOf('/');
            return p <= 0 ? "" : name.Substring(0, p);
        }

        private static int LevelFromName(string name)
        {
            if (String.IsNullOrWhiteSpace(name)) return 0;
            int level = 0;
            foreach (char ch in name) if (ch == '/') level++;
            return level;
        }

        private static void CollectFeatureDimensions(Feature f, List<AsmDimensionInfo> dims)
        {
            object current = null;
            try { current = f.GetFirstDisplayDimension(); } catch { return; }
            int guard = 0;
            while (current != null && guard++ < 100)
            {
                try
                {
                    DisplayDimension dd = current as DisplayDimension;
                    if (dd != null)
                    {
                        Dimension d = dd.GetDimension2(0);
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
                try { current = f.GetNextDisplayDimension(current); }
                catch { break; }
            }
        }

        private static void CollectComponents(AssemblyDoc assy, RefAssemblyReport report)
        {
            object raw = assy.GetComponents(false);
            Array components = raw as Array;
            if (components == null) return;

            int order = 0;
            foreach (object o in components)
            {
                Component2 c = o as Component2;
                if (c == null) continue;

                RefComponentInfo ci = new RefComponentInfo();
                ci.Order = ++order;
                try { ci.Name = c.Name2; } catch { ci.Name = ""; }
                ci.ParentName = ParentFromName(ci.Name);
                ci.Level = LevelFromName(ci.Name);
                try { ci.Path = c.GetPathName(); } catch { ci.Path = ""; }
                try { ci.ReferencedConfiguration = c.ReferencedConfiguration; } catch { ci.ReferencedConfiguration = ""; }
                try { ci.DocumentType = c.GetType(); } catch { ci.DocumentType = 0; }
                try { ci.SuppressionState = c.GetSuppression(); } catch { ci.SuppressionState = -1; }
                try { ci.Hidden = c.IsHidden(true); } catch { ci.Hidden = false; }
                try { ci.Fixed = c.IsFixed(); } catch { ci.Fixed = false; }
                ci.MissingReference = !String.IsNullOrWhiteSpace(ci.Path) && !File.Exists(ci.Path);
                if (ci.MissingReference) report.MissingReferenceCount++;

                ci.Transform = new double[0];
                try
                {
                    MathTransform t = c.Transform2;
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

        private static void CollectMateFeature(Feature mateFeature, string assemblyPath, RefAssemblyReport report, ref int order)
        {
            if (mateFeature == null) return;
            string typeName = "";
            try { typeName = mateFeature.GetTypeName2(); } catch { }
            if (String.IsNullOrWhiteSpace(typeName) || !typeName.StartsWith("Mate", StringComparison.OrdinalIgnoreCase)) return;

            RefMateInfo mi = new RefMateInfo();
            mi.Order = ++order;
            mi.AssemblyPath = assemblyPath;
            mi.Name = mateFeature.Name;
            mi.TypeName = typeName;
            try { mi.Suppressed = mateFeature.IsSuppressed(); } catch { mi.Suppressed = false; }
            CollectFeatureDimensions(mateFeature, mi.Dimensions);

            try
            {
                object specific = mateFeature.GetSpecificFeature2();
                Mate2 mate = specific as Mate2;
                if (mate != null)
                {
                    try { mi.Alignment = mate.Alignment; } catch { mi.Alignment = 0; }
                    int n = 0;
                    try { n = mate.GetMateEntityCount(); } catch { n = 0; }
                    for (int i = 0; i < n; i++)
                    {
                        try
                        {
                            object rawEntity = mate.MateEntity(i);
                            MateEntity2 e = rawEntity as MateEntity2;
                            if (e == null) continue;
                            RefMateEntityInfo ei = new RefMateEntityInfo();
                            ei.Index = i;
                            try { ei.ReferenceType = e.ReferenceType2; } catch { ei.ReferenceType = 0; }
                            try { ei.EntityParams = ToDoubleArray(e.EntityParams); } catch { ei.EntityParams = new double[0]; }
                            try
                            {
                                object rawComponent = e.ReferenceComponent;
                                Component2 rc = rawComponent as Component2;
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

        private static void CollectMates(ModelDoc2 model, string assemblyPath, RefAssemblyReport report)
        {
            int order = 0;
            Feature f = null;
            try { f = model.FirstFeature() as Feature; } catch { }
            int guard = 0;
            while (f != null && guard++ < 5000)
            {
                string type = "";
                try { type = f.GetTypeName2(); } catch { }
                if (String.Equals(type, "MateGroup", StringComparison.OrdinalIgnoreCase))
                {
                    Feature sub = FirstSubFeature(f);
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

        public static RefAssemblyReport Inspect(object sessionObject, string assemblyPath)
        {
            SldWorks app = GetSessionApp(sessionObject);
            string revision = GetSessionRevision(sessionObject);
            if (String.IsNullOrWhiteSpace(assemblyPath) || !File.Exists(assemblyPath))
                throw new FileNotFoundException("Reference SLDASM not found", assemblyPath);

            int errors = 0;
            int warnings = 0;
            ModelDoc2 model = null;
            bool openedHere = false;

            string fullPath = Path.GetFullPath(assemblyPath);
            string workingDir = Path.GetDirectoryName(fullPath);
            if (!String.IsNullOrWhiteSpace(workingDir))
            {
                try { app.SetCurrentWorkingDirectory(workingDir); } catch { }
            }

            try { model = app.GetOpenDocumentByName(fullPath) as ModelDoc2; } catch { }
            if (model == null)
            {
                int openOptions =
                    (int)swOpenDocOptions_e.swOpenDocOptions_Silent |
                    (int)swOpenDocOptions_e.swOpenDocOptions_ReadOnly |
                    (int)swOpenDocOptions_e.swOpenDocOptions_OverrideDefaultLoadLightweight |
                    (int)swOpenDocOptions_e.swOpenDocOptions_LoadLightweight;

                object opened = app.OpenDoc6(
                    fullPath,
                    (int)swDocumentTypes_e.swDocASSEMBLY,
                    openOptions,
                    "",
                    ref errors,
                    ref warnings);
                model = opened as ModelDoc2;
                openedHere = true;
            }
            if (model == null)
                throw new InvalidOperationException("SOLIDWORKS could not open reference assembly. OpenErrors=" + errors + ", OpenWarnings=" + warnings);

            try
            {
                AssemblyDoc assy = model as AssemblyDoc;
                if (assy == null) throw new InvalidOperationException("Opened document is not an AssemblyDoc.");

                RefAssemblyReport report = new RefAssemblyReport();
                report.Path = fullPath;
                report.Title = model.GetTitle();
                report.Revision = revision;
                report.OpenErrors = errors;
                report.OpenWarnings = warnings;
                try { report.ActiveConfiguration = model.ConfigurationManager.ActiveConfiguration.Name; } catch { report.ActiveConfiguration = ""; }
                try { report.LightweightComponentCount = assy.GetLightWeightComponentCount(); } catch { report.LightweightComponentCount = -1; }

                CollectComponents(assy, report);
                CollectMates(model, report.Path, report);
                return report;
            }
            finally
            {
                if (openedHere)
                {
                    try { app.CloseDoc(model.GetTitle()); } catch { }
                }
            }
        }
    }
}
'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

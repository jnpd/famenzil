function Add-EmbeddedSwReferenceInspectorApiType {
    if ('Q347F.SwReferenceInspectorApi' -as [type]) { return }

    $source = @'
using Sys = System;
using IO = System.IO;
using Collections = System.Collections.Generic;
using SW = SolidWorks.Interop.sldworks;
using SWC = SolidWorks.Interop.swconst;

namespace Q347F
{
    public sealed class RefDimensionInfo
    {
        public string Name;
        public string FullName;
        public double SystemValue;
        public double ApproxMm;
        public string FeatureName;
    }

    public sealed class RefFeatureInfo
    {
        public int Order;
        public int Level;
        public string Name;
        public string TypeName;
        public string ParentName;
        public bool Suppressed;
        public Collections.List<RefDimensionInfo> Dimensions = new Collections.List<RefDimensionInfo>();
    }

    public sealed class RefPartReport
    {
        public string Path;
        public string Title;
        public string ActiveConfiguration;
        public string Revision;
        public int OpenErrors;
        public int OpenWarnings;
        public int FeatureCount;
        public int SolidBodyCount;
        public double[] BoundingBoxMm;
        public double[] MaterialPropertyValues;
        public string[] Equations;
        public Collections.List<RefFeatureInfo> Features = new Collections.List<RefFeatureInfo>();
    }

    public static class SwReferenceInspectorApi
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

        private static void CollectDimensions(SW.Feature f, RefFeatureInfo fi)
        {
            object current = null;
            try { current = f.GetFirstDisplayDimension(); } catch { return; }
            int guard = 0;
            while (current != null && guard++ < 200)
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
                            fi.Dimensions.Add(new RefDimensionInfo
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

        private static void CollectFeatureRecursive(SW.Feature f, int level, string parent, RefPartReport report, ref int order)
        {
            if (f == null) return;
            RefFeatureInfo fi = new RefFeatureInfo();
            fi.Order = ++order;
            fi.Level = level;
            try { fi.Name = f.Name; } catch { fi.Name = ""; }
            fi.ParentName = parent ?? "";
            try { fi.TypeName = f.GetTypeName2(); } catch { fi.TypeName = ""; }
            try { fi.Suppressed = f.IsSuppressed(); } catch { fi.Suppressed = false; }
            CollectDimensions(f, fi);
            report.Features.Add(fi);

            SW.Feature sub = FirstSubFeature(f);
            int guard = 0;
            while (sub != null && guard++ < 500)
            {
                CollectFeatureRecursive(sub, level + 1, fi.Name, report, ref order);
                sub = NextSubFeature(sub);
            }
        }

        private static string[] ReadEquations(SW.ModelDoc2 model)
        {
            try
            {
                SW.EquationMgr mgr = model.GetEquationMgr();
                if (mgr == null) return new string[0];
                int n = mgr.GetCount();
                Collections.List<string> eq = new Collections.List<string>();
                for (int i = 0; i < n; i++) { try { eq.Add(mgr.get_Equation(i)); } catch { } }
                return eq.ToArray();
            }
            catch { return new string[0]; }
        }

        private static double[] ReadBoundingBoxMm(SW.ModelDoc2 model, out int bodyCount)
        {
            bodyCount = 0;
            SW.PartDoc part = model as SW.PartDoc;
            if (part == null) return new double[0];
            try
            {
                Sys.Array bodies = part.GetBodies2((int)SWC.swBodyType_e.swSolidBody, true) as Sys.Array;
                bodyCount = bodies == null ? 0 : bodies.Length;
            }
            catch { }
            try
            {
                Sys.Array box = part.GetPartBox(true) as Sys.Array;
                if (box == null || box.Length < 6) return new double[0];
                double[] mm = new double[6];
                for (int i = 0; i < 6; i++) mm[i] = Sys.Convert.ToDouble(box.GetValue(i)) * 1000.0;
                return mm;
            }
            catch { return new double[0]; }
        }

        private static double[] ReadMaterial(SW.ModelDoc2 model)
        {
            try
            {
                Sys.Array a = model.MaterialPropertyValues as Sys.Array;
                if (a == null) return new double[0];
                double[] v = new double[a.Length];
                for (int i = 0; i < a.Length; i++) v[i] = Sys.Convert.ToDouble(a.GetValue(i));
                return v;
            }
            catch { return new double[0]; }
        }

        public static RefPartReport Inspect(object appObject, string revision, string partPath)
        {
            SW.SldWorks app = appObject as SW.SldWorks;
            if (app == null) throw new Sys.ArgumentException("appObject is not a SOLIDWORKS SldWorks application.");
            if (Sys.String.IsNullOrWhiteSpace(partPath) || !IO.File.Exists(partPath))
                throw new IO.FileNotFoundException("Reference SLDPRT not found", partPath);

            string fullPath = IO.Path.GetFullPath(partPath);
            string workingDir = IO.Path.GetDirectoryName(fullPath);
            if (!Sys.String.IsNullOrWhiteSpace(workingDir)) { try { app.SetCurrentWorkingDirectory(workingDir); } catch { } }

            int errors = 0;
            int warnings = 0;
            SW.ModelDoc2 model = FindOpenDocumentByPathOrTitle(app, fullPath);
            bool openedHere = false;
            if (model == null)
            {
                object opened = app.OpenDoc6(
                    fullPath,
                    (int)SWC.swDocumentTypes_e.swDocPART,
                    (int)(SWC.swOpenDocOptions_e.swOpenDocOptions_Silent | SWC.swOpenDocOptions_e.swOpenDocOptions_ReadOnly),
                    "", ref errors, ref warnings);
                model = opened as SW.ModelDoc2;
                openedHere = model != null;

                if (model == null && errors == 65536)
                {
                    model = FindOpenDocumentByPathOrTitle(app, fullPath);
                    openedHere = false;
                }
            }
            if (model == null)
                throw new Sys.InvalidOperationException("SOLIDWORKS could not open reference part. OpenErrors=" + errors + ", OpenWarnings=" + warnings + ", Path=" + fullPath);

            try
            {
                RefPartReport report = new RefPartReport();
                report.Path = fullPath;
                report.Title = model.GetTitle();
                report.Revision = revision ?? "";
                report.OpenErrors = errors;
                report.OpenWarnings = warnings;
                try { report.ActiveConfiguration = model.ConfigurationManager.ActiveConfiguration.Name; } catch { report.ActiveConfiguration = ""; }
                report.Equations = ReadEquations(model);
                report.MaterialPropertyValues = ReadMaterial(model);
                int bodyCount = 0;
                report.BoundingBoxMm = ReadBoundingBoxMm(model, out bodyCount);
                report.SolidBodyCount = bodyCount;

                int order = 0;
                SW.Feature f = null;
                try { f = model.FirstFeature() as SW.Feature; } catch { }
                int guard = 0;
                while (f != null && guard++ < 2000)
                {
                    CollectFeatureRecursive(f, 0, "", report, ref order);
                    f = NextFeature(f);
                }
                report.FeatureCount = report.Features.Count;
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

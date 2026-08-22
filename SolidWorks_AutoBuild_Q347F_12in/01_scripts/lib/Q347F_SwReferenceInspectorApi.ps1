function Add-EmbeddedSwReferenceInspectorApiType {
    if ('Q347F.SwReferenceInspectorApi' -as [type]) { return }

    $source = @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

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
        public List<RefDimensionInfo> Dimensions = new List<RefDimensionInfo>();
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
        public List<RefFeatureInfo> Features = new List<RefFeatureInfo>();
    }

    public static class SwReferenceInspectorApi
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

        private static void CollectDimensions(Feature f, RefFeatureInfo fi)
        {
            object current = null;
            try { current = f.GetFirstDisplayDimension(); } catch { return; }
            int guard = 0;
            while (current != null && guard++ < 200)
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

                try { current = f.GetNextDisplayDimension(current); }
                catch { break; }
            }
        }

        private static void CollectFeatureRecursive(Feature f, int level, string parent, RefPartReport report, ref int order)
        {
            if (f == null) return;
            RefFeatureInfo fi = new RefFeatureInfo();
            fi.Order = ++order;
            fi.Level = level;
            fi.Name = f.Name;
            fi.ParentName = parent ?? "";
            try { fi.TypeName = f.GetTypeName2(); } catch { fi.TypeName = ""; }
            try { fi.Suppressed = f.IsSuppressed(); } catch { fi.Suppressed = false; }
            CollectDimensions(f, fi);
            report.Features.Add(fi);

            Feature sub = FirstSubFeature(f);
            int guard = 0;
            while (sub != null && guard++ < 500)
            {
                CollectFeatureRecursive(sub, level + 1, f.Name, report, ref order);
                sub = NextSubFeature(sub);
            }
        }

        private static string[] ReadEquations(ModelDoc2 model)
        {
            try
            {
                EquationMgr mgr = model.GetEquationMgr();
                if (mgr == null) return new string[0];
                int n = mgr.GetCount();
                List<string> eq = new List<string>();
                for (int i = 0; i < n; i++)
                {
                    try { eq.Add(mgr.get_Equation(i)); } catch { }
                }
                return eq.ToArray();
            }
            catch { return new string[0]; }
        }

        private static double[] ReadBoundingBoxMm(ModelDoc2 model, out int bodyCount)
        {
            bodyCount = 0;
            PartDoc part = model as PartDoc;
            if (part == null) return new double[0];

            try
            {
                object rawBodies = part.GetBodies2((int)swBodyType_e.swSolidBody, true);
                Array bodies = rawBodies as Array;
                bodyCount = bodies == null ? 0 : bodies.Length;
            }
            catch { }

            try
            {
                Array box = part.GetPartBox(true) as Array;
                if (box == null || box.Length < 6) return new double[0];
                double[] mm = new double[6];
                for (int i = 0; i < 6; i++) mm[i] = Convert.ToDouble(box.GetValue(i)) * 1000.0;
                return mm;
            }
            catch { return new double[0]; }
        }

        private static double[] ReadMaterial(ModelDoc2 model)
        {
            try
            {
                Array a = model.MaterialPropertyValues as Array;
                if (a == null) return new double[0];
                double[] v = new double[a.Length];
                for (int i = 0; i < a.Length; i++) v[i] = Convert.ToDouble(a.GetValue(i));
                return v;
            }
            catch { return new double[0]; }
        }

        public static RefPartReport Inspect(object sessionObject, string partPath)
        {
            SldWorks app = GetSessionApp(sessionObject);
            string revision = GetSessionRevision(sessionObject);
            if (String.IsNullOrWhiteSpace(partPath) || !File.Exists(partPath))
                throw new FileNotFoundException("Reference SLDPRT not found", partPath);

            int errors = 0;
            int warnings = 0;
            ModelDoc2 model = null;
            bool openedHere = false;

            try { model = app.GetOpenDocumentByName(partPath) as ModelDoc2; } catch { }

            if (model == null)
            {
                object opened = app.OpenDoc6(
                    partPath,
                    (int)swDocumentTypes_e.swDocPART,
                    (int)(swOpenDocOptions_e.swOpenDocOptions_Silent | swOpenDocOptions_e.swOpenDocOptions_ReadOnly),
                    "",
                    ref errors,
                    ref warnings);
                model = opened as ModelDoc2;
                openedHere = true;
            }

            if (model == null)
                throw new InvalidOperationException("SOLIDWORKS could not open reference part. OpenErrors=" + errors + ", OpenWarnings=" + warnings);

            try
            {
                RefPartReport report = new RefPartReport();
                report.Path = Path.GetFullPath(partPath);
                report.Title = model.GetTitle();
                report.Revision = revision;
                report.OpenErrors = errors;
                report.OpenWarnings = warnings;
                try { report.ActiveConfiguration = model.ConfigurationManager.ActiveConfiguration.Name; } catch { report.ActiveConfiguration = ""; }
                report.Equations = ReadEquations(model);
                report.MaterialPropertyValues = ReadMaterial(model);
                int bodyCount = 0;
                report.BoundingBoxMm = ReadBoundingBoxMm(model, out bodyCount);
                report.SolidBodyCount = bodyCount;

                int order = 0;
                Feature f = null;
                try { f = model.FirstFeature() as Feature; } catch { }
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

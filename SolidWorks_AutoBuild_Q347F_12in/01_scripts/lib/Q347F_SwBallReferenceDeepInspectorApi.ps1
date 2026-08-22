function Add-EmbeddedSwBallReferenceDeepInspectorApiType {
    if ('Q347F.SwBallReferenceDeepInspectorApi' -as [type]) { return }

    $source = @'
using Sys = System;
using IO = System.IO;
using Collections = System.Collections.Generic;
using SW = SolidWorks.Interop.sldworks;
using SWC = SolidWorks.Interop.swconst;

namespace Q347F
{
    public sealed class RefBallSketchInfo
    {
        public string SketchName;
        public int SegmentCount;
        public int PointCount;
        public string ModelToSketchTransform;
        public double XMinMm;
        public double XMaxMm;
        public double YMinMm;
        public double YMaxMm;
        public double ZMinMm;
        public double ZMaxMm;
    }

    public sealed class RefBallSketchSegmentInfo
    {
        public string SketchName;
        public int SegmentIndex;
        public string Kind;
        public bool Construction;
        public double LengthMm;
        public double StartXmm;
        public double StartYmm;
        public double StartZmm;
        public double EndXmm;
        public double EndYmm;
        public double EndZmm;
        public double CenterXmm;
        public double CenterYmm;
        public double CenterZmm;
        public double RadiusMm;
        public bool IsCircle;
        public int RotationDir;
    }

    public sealed class RefBallSketchPointInfo
    {
        public string SketchName;
        public int PointIndex;
        public double Xmm;
        public double Ymm;
        public double Zmm;
    }

    public sealed class RefBallFeatureDefinitionInfo
    {
        public int Order;
        public string FeatureName;
        public string TypeName2;
        public string UnderlyingType;
        public string DefinitionKind;
        public string Summary;
    }

    public sealed class RefBallDeepReport
    {
        public string Path;
        public string Title;
        public string Configuration;
        public int OpenErrors;
        public int OpenWarnings;
        public Collections.List<RefBallSketchInfo> Sketches = new Collections.List<RefBallSketchInfo>();
        public Collections.List<RefBallSketchSegmentInfo> Segments = new Collections.List<RefBallSketchSegmentInfo>();
        public Collections.List<RefBallSketchPointInfo> Points = new Collections.List<RefBallSketchPointInfo>();
        public Collections.List<RefBallFeatureDefinitionInfo> FeatureDefinitions = new Collections.List<RefBallFeatureDefinitionInfo>();
    }

    public static class SwBallReferenceDeepInspectorApi
    {
        private static double Mm(double m) { return m * 1000.0; }

        private static SW.ModelDoc2 FindOpenDocument(SW.SldWorks app, string fullPath)
        {
            if (app == null) return null;
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
                    string p = "";
                    string t = "";
                    try { p = cur.GetPathName(); } catch { }
                    try { t = cur.GetTitle(); } catch { }
                    if (!Sys.String.IsNullOrWhiteSpace(p))
                    {
                        string np;
                        try { np = IO.Path.GetFullPath(p); } catch { np = p; }
                        if (Sys.String.Equals(np, target, Sys.StringComparison.OrdinalIgnoreCase)) return cur;
                    }
                    if (Sys.String.Equals(t, titleWanted, Sys.StringComparison.OrdinalIgnoreCase)) return cur;
                    try { cur = cur.GetNext() as SW.ModelDoc2; } catch { cur = null; }
                }
            }
            catch { }
            return null;
        }

        private static string TransformText(SW.Sketch sketch)
        {
            try
            {
                SW.MathTransform mt = sketch.ModelToSketchTransform;
                if (mt == null) return "";
                Sys.Array a = mt.ArrayData as Sys.Array;
                if (a == null) return "";
                Collections.List<string> s = new Collections.List<string>();
                for (int i = 0; i < a.Length; i++) s.Add(Sys.Convert.ToDouble(a.GetValue(i)).ToString("R", Sys.Globalization.CultureInfo.InvariantCulture));
                return Sys.String.Join(";", s.ToArray());
            }
            catch { return ""; }
        }

        private static void Expand(ref double min, ref double max, double value)
        {
            if (value < min) min = value;
            if (value > max) max = value;
        }

        private static void ReadPoint(SW.SketchPoint p, out double x, out double y, out double z)
        {
            x = y = z = 0.0;
            if (p == null) return;
            x = Mm(p.X); y = Mm(p.Y); z = Mm(p.Z);
        }

        private static void CollectSketch(SW.Feature feature, RefBallDeepReport report)
        {
            SW.Sketch sketch = null;
            try { sketch = feature.GetSpecificFeature2() as SW.Sketch; } catch { }
            if (sketch == null) return;

            RefBallSketchInfo si = new RefBallSketchInfo();
            si.SketchName = feature.Name;
            si.ModelToSketchTransform = TransformText(sketch);
            si.XMinMm = si.YMinMm = si.ZMinMm = Sys.Double.PositiveInfinity;
            si.XMaxMm = si.YMaxMm = si.ZMaxMm = Sys.Double.NegativeInfinity;

            Sys.Array segs = null;
            try { segs = sketch.GetSketchSegments() as Sys.Array; } catch { }
            si.SegmentCount = segs == null ? 0 : segs.Length;
            if (segs != null)
            {
                int index = 0;
                foreach (object o in segs)
                {
                    index++;
                    SW.SketchSegment seg = o as SW.SketchSegment;
                    if (seg == null) continue;
                    RefBallSketchSegmentInfo row = new RefBallSketchSegmentInfo();
                    row.SketchName = si.SketchName;
                    row.SegmentIndex = index;
                    try { row.Construction = seg.ConstructionGeometry; } catch { }
                    try { row.LengthMm = Mm(seg.GetLength()); } catch { }

                    SW.SketchLine line = o as SW.SketchLine;
                    if (line != null)
                    {
                        row.Kind = "LINE";
                        SW.SketchPoint p0 = null, p1 = null;
                        try { p0 = line.GetStartPoint2() as SW.SketchPoint; } catch { }
                        try { p1 = line.GetEndPoint2() as SW.SketchPoint; } catch { }
                        ReadPoint(p0, out row.StartXmm, out row.StartYmm, out row.StartZmm);
                        ReadPoint(p1, out row.EndXmm, out row.EndYmm, out row.EndZmm);
                        Expand(ref si.XMinMm, ref si.XMaxMm, row.StartXmm); Expand(ref si.XMinMm, ref si.XMaxMm, row.EndXmm);
                        Expand(ref si.YMinMm, ref si.YMaxMm, row.StartYmm); Expand(ref si.YMinMm, ref si.YMaxMm, row.EndYmm);
                        Expand(ref si.ZMinMm, ref si.ZMaxMm, row.StartZmm); Expand(ref si.ZMinMm, ref si.ZMaxMm, row.EndZmm);
                    }
                    else
                    {
                        SW.SketchArc arc = o as SW.SketchArc;
                        if (arc != null)
                        {
                            try { row.IsCircle = arc.IsCircle() == 1; } catch { }
                            row.Kind = row.IsCircle ? "CIRCLE" : "ARC";
                            SW.SketchPoint p0 = null, p1 = null, pc = null;
                            try { p0 = arc.GetStartPoint2() as SW.SketchPoint; } catch { }
                            try { p1 = arc.GetEndPoint2() as SW.SketchPoint; } catch { }
                            try { pc = arc.GetCenterPoint2() as SW.SketchPoint; } catch { }
                            ReadPoint(p0, out row.StartXmm, out row.StartYmm, out row.StartZmm);
                            ReadPoint(p1, out row.EndXmm, out row.EndYmm, out row.EndZmm);
                            ReadPoint(pc, out row.CenterXmm, out row.CenterYmm, out row.CenterZmm);
                            try { row.RadiusMm = Mm(arc.GetRadius()); } catch { }
                            try { row.RotationDir = arc.GetRotationDir(); } catch { }
                            double r = row.RadiusMm;
                            Expand(ref si.XMinMm, ref si.XMaxMm, row.CenterXmm - r); Expand(ref si.XMinMm, ref si.XMaxMm, row.CenterXmm + r);
                            Expand(ref si.YMinMm, ref si.YMaxMm, row.CenterYmm - r); Expand(ref si.YMinMm, ref si.YMaxMm, row.CenterYmm + r);
                            Expand(ref si.ZMinMm, ref si.ZMaxMm, row.CenterZmm - r); Expand(ref si.ZMinMm, ref si.ZMaxMm, row.CenterZmm + r);
                        }
                        else
                        {
                            row.Kind = "OTHER";
                        }
                    }
                    report.Segments.Add(row);
                }
            }

            Sys.Array pts = null;
            try { pts = sketch.GetSketchPoints2() as Sys.Array; } catch { }
            si.PointCount = pts == null ? 0 : pts.Length;
            if (pts != null)
            {
                int pi = 0;
                foreach (object o in pts)
                {
                    pi++;
                    SW.SketchPoint p = o as SW.SketchPoint;
                    if (p == null) continue;
                    RefBallSketchPointInfo pr = new RefBallSketchPointInfo();
                    pr.SketchName = si.SketchName;
                    pr.PointIndex = pi;
                    ReadPoint(p, out pr.Xmm, out pr.Ymm, out pr.Zmm);
                    Expand(ref si.XMinMm, ref si.XMaxMm, pr.Xmm);
                    Expand(ref si.YMinMm, ref si.YMaxMm, pr.Ymm);
                    Expand(ref si.ZMinMm, ref si.ZMaxMm, pr.Zmm);
                    report.Points.Add(pr);
                }
            }

            if (Sys.Double.IsPositiveInfinity(si.XMinMm)) si.XMinMm = si.XMaxMm = 0.0;
            if (Sys.Double.IsPositiveInfinity(si.YMinMm)) si.YMinMm = si.YMaxMm = 0.0;
            if (Sys.Double.IsPositiveInfinity(si.ZMinMm)) si.ZMinMm = si.ZMaxMm = 0.0;
            report.Sketches.Add(si);
        }

        private static string FeatureDefinitionSummary(SW.Feature f, string underlying, out string kind)
        {
            kind = "";
            object def = null;
            try { def = f.GetDefinition(); } catch { }
            if (def == null) return "";

            SW.ExtrudeFeatureData2 ex = def as SW.ExtrudeFeatureData2;
            if (ex != null)
            {
                kind = "IExtrudeFeatureData2";
                double d1 = 0.0, d2 = 0.0;
                try { d1 = Mm(ex.GetDepth(true)); } catch { }
                try { d2 = Mm(ex.GetDepth(false)); } catch { }
                return "Depth1_mm=" + d1.ToString("0.###", Sys.Globalization.CultureInfo.InvariantCulture) + ";Depth2_mm=" + d2.ToString("0.###", Sys.Globalization.CultureInfo.InvariantCulture);
            }

            SW.RevolveFeatureData2 rv = def as SW.RevolveFeatureData2;
            if (rv != null)
            {
                kind = "IRevolveFeatureData2";
                double a1 = 0.0, a2 = 0.0;
                try { a1 = rv.GetRevolutionAngle(true) * 180.0 / Sys.Math.PI; } catch { }
                try { a2 = rv.GetRevolutionAngle(false) * 180.0 / Sys.Math.PI; } catch { }
                return "Angle1_deg=" + a1.ToString("0.###", Sys.Globalization.CultureInfo.InvariantCulture) + ";Angle2_deg=" + a2.ToString("0.###", Sys.Globalization.CultureInfo.InvariantCulture);
            }

            kind = "COM_DEFINITION";
            return "DefinitionAvailable=true;UnderlyingType=" + (underlying ?? "");
        }

        public static RefBallDeepReport Inspect(object appObject, string partPath)
        {
            SW.SldWorks app = appObject as SW.SldWorks;
            if (app == null) throw new Sys.ArgumentException("appObject is not a SOLIDWORKS application.");
            if (Sys.String.IsNullOrWhiteSpace(partPath) || !IO.File.Exists(partPath)) throw new IO.FileNotFoundException("20in reference BALL not found", partPath);

            string fullPath = IO.Path.GetFullPath(partPath);
            int errors = 0, warnings = 0;
            SW.ModelDoc2 model = FindOpenDocument(app, fullPath);
            bool openedHere = false;
            if (model == null)
            {
                object opened = app.OpenDoc6(fullPath, (int)SWC.swDocumentTypes_e.swDocPART,
                    (int)(SWC.swOpenDocOptions_e.swOpenDocOptions_Silent | SWC.swOpenDocOptions_e.swOpenDocOptions_ReadOnly),
                    "", ref errors, ref warnings);
                model = opened as SW.ModelDoc2;
                openedHere = model != null;
                if (model == null && errors == 65536) model = FindOpenDocument(app, fullPath);
            }
            if (model == null) throw new Sys.InvalidOperationException("SOLIDWORKS could not open 20in reference BALL. errors=" + errors + " warnings=" + warnings);

            try
            {
                RefBallDeepReport report = new RefBallDeepReport();
                report.Path = fullPath;
                report.Title = model.GetTitle();
                report.OpenErrors = errors;
                report.OpenWarnings = warnings;
                try { report.Configuration = model.ConfigurationManager.ActiveConfiguration.Name; } catch { report.Configuration = ""; }

                SW.Feature f = null;
                try { f = model.FirstFeature() as SW.Feature; } catch { }
                int order = 0, guard = 0;
                while (f != null && guard++ < 2000)
                {
                    order++;
                    string t2 = "", underlying = "";
                    try { t2 = f.GetTypeName2(); } catch { }
                    try { underlying = f.GetTypeName(); } catch { underlying = t2; }

                    if (Sys.String.Equals(t2, "ProfileFeature", Sys.StringComparison.OrdinalIgnoreCase) ||
                        Sys.String.Equals(t2, "3DProfileFeature", Sys.StringComparison.OrdinalIgnoreCase))
                        CollectSketch(f, report);

                    string dk = "";
                    string ds = FeatureDefinitionSummary(f, underlying, out dk);
                    if (!Sys.String.IsNullOrWhiteSpace(ds))
                    {
                        report.FeatureDefinitions.Add(new RefBallFeatureDefinitionInfo {
                            Order = order,
                            FeatureName = f.Name,
                            TypeName2 = t2,
                            UnderlyingType = underlying,
                            DefinitionKind = dk,
                            Summary = ds
                        });
                    }
                    try { f = f.GetNextFeature() as SW.Feature; } catch { f = null; }
                }
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

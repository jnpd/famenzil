function Add-EmbeddedSwBallApiType {
    if ('Q347F.SwBallApi' -as [type]) { return }

    $source = @'
using System;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

namespace Q347F
{
    public sealed class BallAudit
    {
        public int SolidBodyCount;
        public double XMinMm;
        public double XMaxMm;
        public double YMinMm;
        public double YMaxMm;
        public double ZMinMm;
        public double ZMaxMm;
    }

    public static class SwBallApi
    {
        private static ModelDoc2 AsModel(object modelObject)
        {
            if (modelObject == null) throw new ArgumentNullException("modelObject");
            return (ModelDoc2)modelObject;
        }

        private static Feature FindFeatureByName(ModelDoc2 model, string name)
        {
            Feature f = (Feature)model.FirstFeature();
            while (f != null)
            {
                if (String.Equals(f.Name, name, StringComparison.OrdinalIgnoreCase)) return f;
                f = (Feature)f.GetNextFeature();
            }
            return null;
        }

        private static Feature GetLastSketchFeature(ModelDoc2 model)
        {
            Feature f = (Feature)model.FirstFeature();
            Feature last = null;
            while (f != null)
            {
                string type = "";
                try { type = f.GetTypeName2(); } catch { }
                if (String.Equals(type, "ProfileFeature", StringComparison.OrdinalIgnoreCase) ||
                    String.Equals(type, "3DProfileFeature", StringComparison.OrdinalIgnoreCase)) last = f;
                f = (Feature)f.GetNextFeature();
            }
            return last;
        }

        private static double M(double mm) { return mm / 1000.0; }

        private static Feature FinishSketch(ModelDoc2 model, string sketchName)
        {
            model.SketchManager.InsertSketch(true);
            Feature sketch = GetLastSketchFeature(model);
            if (sketch == null) throw new InvalidOperationException("Cannot locate sketch " + sketchName);
            sketch.Name = sketchName;
            model.ClearSelection2(true);
            return sketch;
        }

        public static string CreateBallCore(object modelObject, string profilePlaneName, string axisName, double ballOdMm, double ballWidthMm)
        {
            ModelDoc2 model = AsModel(modelObject);
            if (ballOdMm <= 0 || ballWidthMm <= 0 || ballWidthMm >= ballOdMm)
                throw new ArgumentException("Invalid ball OD/width.");

            Feature plane = FindFeatureByName(model, profilePlaneName);
            Feature axis = FindFeatureByName(model, axisName);
            if (plane == null) throw new InvalidOperationException("Ball profile plane not found: " + profilePlaneName);
            if (axis == null) throw new InvalidOperationException("Ball revolve axis not found: " + axisName);

            double r = M(ballOdMm / 2.0);
            double hx = M(ballWidthMm / 2.0);
            double edgeR = Math.Sqrt(r * r - hx * hx);

            model.ClearSelection2(true);
            if (!plane.Select2(false, 0)) throw new InvalidOperationException("Cannot select ball profile plane.");
            model.SketchManager.InsertSketch(true);
            model.ClearSelection2(true);

            SketchSegment l1 = model.SketchManager.CreateLine(-hx, 0.0, 0.0, -hx, edgeR, 0.0);
            SketchSegment arc = model.SketchManager.CreateArc(0.0, 0.0, 0.0, -hx, edgeR, 0.0, hx, edgeR, 0.0, -1);
            SketchSegment l2 = model.SketchManager.CreateLine(hx, edgeR, 0.0, hx, 0.0, 0.0);
            SketchSegment l3 = model.SketchManager.CreateLine(hx, 0.0, 0.0, -hx, 0.0, 0.0);
            if (l1 == null || arc == null || l2 == null || l3 == null)
                throw new InvalidOperationException("Failed to create closed ball revolve profile.");

            Feature sketch = FinishSketch(model, "SK_BALL_PROFILE");

            model.ClearSelection2(true);
            if (!sketch.Select2(false, 0)) throw new InvalidOperationException("Cannot select SK_BALL_PROFILE.");
            if (!axis.Select2(true, 16)) throw new InvalidOperationException("Cannot select AXIS_X_FLOW for revolve.");

            Feature revol = model.FeatureManager.FeatureRevolve2(
                true, true, false, false, false, false,
                0, 0, 2.0 * Math.PI, 0.0,
                false, false, 0.0, 0.0,
                0, 0.0, 0.0,
                true, true, true);
            if (revol == null) throw new InvalidOperationException("FeatureRevolve2 returned null for BALL_CORE.");
            revol.Name = "BALL_CORE";
            model.ClearSelection2(true);
            return revol.Name;
        }

        private static Feature CreateCircleSketch(ModelDoc2 model, Feature plane, string sketchName, double diameterMm)
        {
            model.ClearSelection2(true);
            if (!plane.Select2(false, 0)) throw new InvalidOperationException("Cannot select plane for " + sketchName);
            model.SketchManager.InsertSketch(true);
            SketchSegment circle = model.SketchManager.CreateCircleByRadius(0.0, 0.0, 0.0, M(diameterMm / 2.0));
            if (circle == null) throw new InvalidOperationException("CreateCircleByRadius failed for " + sketchName);
            return FinishSketch(model, sketchName);
        }

        private static Feature CutSelectedSketch(ModelDoc2 model, Feature sketch, string featureName, bool throughAllBoth, double depthMm, bool reverseDir)
        {
            model.ClearSelection2(true);
            if (!sketch.Select2(false, 0)) throw new InvalidOperationException("Cannot select sketch for " + featureName);

            int t1 = throughAllBoth ? (int)swEndConditions_e.swEndCondThroughAll : (int)swEndConditions_e.swEndCondBlind;
            int t2 = throughAllBoth ? (int)swEndConditions_e.swEndCondThroughAll : (int)swEndConditions_e.swEndCondBlind;
            double d = M(Math.Max(depthMm, 1.0));

            Feature cut = model.FeatureManager.FeatureCut4(
                !throughAllBoth,
                false,
                reverseDir,
                t1,
                t2,
                d,
                d,
                false,
                false,
                false,
                false,
                0.0,
                0.0,
                false,
                false,
                false,
                false,
                false,
                false,
                true,
                false,
                false,
                false,
                0,
                0.0,
                false,
                false);
            if (cut == null) throw new InvalidOperationException("FeatureCut4 returned null for " + featureName);
            cut.Name = featureName;
            model.ClearSelection2(true);
            return cut;
        }

        public static string CreateThroughBore(object modelObject, string planeName, double diameterMm)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature plane = FindFeatureByName(model, planeName);
            if (plane == null) throw new InvalidOperationException("Bore plane not found: " + planeName);
            Feature sketch = CreateCircleSketch(model, plane, "SK_BORE_D303", diameterMm);
            return CutSelectedSketch(model, sketch, "CUT_BORE_D303", true, 1.0, false).Name;
        }

        public static string CreateBlindRoundCut(object modelObject, string planeName, string sketchName, string featureName, double diameterMm, double depthMm, bool reverseDir)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature plane = FindFeatureByName(model, planeName);
            if (plane == null) throw new InvalidOperationException("Blind-cut plane not found: " + planeName);
            Feature sketch = CreateCircleSketch(model, plane, sketchName, diameterMm);
            return CutSelectedSketch(model, sketch, featureName, false, depthMm, reverseDir).Name;
        }

        public static string CreateRoundedRectangleBlindCut(object modelObject, string planeName, double lengthXmm, double widthYmm, double cornerRmm, double depthMm, bool reverseDir)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature plane = FindFeatureByName(model, planeName);
            if (plane == null) throw new InvalidOperationException("Drive-slot plane not found: " + planeName);
            if (lengthXmm <= 2.0 * cornerRmm || widthYmm <= 2.0 * cornerRmm)
                throw new ArgumentException("Rounded rectangle is too small for the requested corner radius.");

            double hx = M(lengthXmm / 2.0);
            double hy = M(widthYmm / 2.0);
            double rr = M(cornerRmm);
            double ix = hx - rr;
            double iy = hy - rr;

            model.ClearSelection2(true);
            if (!plane.Select2(false, 0)) throw new InvalidOperationException("Cannot select drive-slot plane.");
            model.SketchManager.InsertSketch(true);
            model.ClearSelection2(true);

            SketchSegment s1 = model.SketchManager.CreateLine(-ix, hy, 0, ix, hy, 0);
            SketchSegment a1 = model.SketchManager.CreateArc(ix, iy, 0, ix, hy, 0, hx, iy, 0, -1);
            SketchSegment s2 = model.SketchManager.CreateLine(hx, iy, 0, hx, -iy, 0);
            SketchSegment a2 = model.SketchManager.CreateArc(ix, -iy, 0, hx, -iy, 0, ix, -hy, 0, -1);
            SketchSegment s3 = model.SketchManager.CreateLine(ix, -hy, 0, -ix, -hy, 0);
            SketchSegment a3 = model.SketchManager.CreateArc(-ix, -iy, 0, -ix, -hy, 0, -hx, -iy, 0, -1);
            SketchSegment s4 = model.SketchManager.CreateLine(-hx, -iy, 0, -hx, iy, 0);
            SketchSegment a4 = model.SketchManager.CreateArc(-ix, iy, 0, -hx, iy, 0, -ix, hy, 0, -1);
            if (s1 == null || a1 == null || s2 == null || a2 == null || s3 == null || a3 == null || s4 == null || a4 == null)
                throw new InvalidOperationException("Failed to create rounded drive-slot sketch.");

            Feature sketch = FinishSketch(model, "SK_UPPER_DRIVE_SLOT_70x50_R8");
            return CutSelectedSketch(model, sketch, "CUT_UPPER_DRIVE_SLOT_70x50_R8", false, depthMm, reverseDir).Name;
        }

        public static BallAudit Audit(object modelObject)
        {
            ModelDoc2 model = AsModel(modelObject);
            PartDoc part = model as PartDoc;
            if (part == null) throw new InvalidOperationException("Ball document is not a PartDoc.");

            object raw = part.GetBodies2((int)swBodyType_e.swSolidBody, true);
            Array bodies = raw as Array;
            BallAudit result = new BallAudit
            {
                SolidBodyCount = bodies == null ? 0 : bodies.Length,
                XMinMm = Double.PositiveInfinity,
                XMaxMm = Double.NegativeInfinity,
                YMinMm = Double.PositiveInfinity,
                YMaxMm = Double.NegativeInfinity,
                ZMinMm = Double.PositiveInfinity,
                ZMaxMm = Double.NegativeInfinity
            };

            if (bodies != null)
            {
                foreach (object o in bodies)
                {
                    Body2 body = o as Body2;
                    if (body == null) continue;
                    Array box = body.GetBodyBox() as Array;
                    if (box == null || box.Length < 6) continue;
                    double x0 = Convert.ToDouble(box.GetValue(0)) * 1000.0;
                    double y0 = Convert.ToDouble(box.GetValue(1)) * 1000.0;
                    double z0 = Convert.ToDouble(box.GetValue(2)) * 1000.0;
                    double x1 = Convert.ToDouble(box.GetValue(3)) * 1000.0;
                    double y1 = Convert.ToDouble(box.GetValue(4)) * 1000.0;
                    double z1 = Convert.ToDouble(box.GetValue(5)) * 1000.0;
                    result.XMinMm = Math.Min(result.XMinMm, Math.Min(x0, x1));
                    result.XMaxMm = Math.Max(result.XMaxMm, Math.Max(x0, x1));
                    result.YMinMm = Math.Min(result.YMinMm, Math.Min(y0, y1));
                    result.YMaxMm = Math.Max(result.YMaxMm, Math.Max(y0, y1));
                    result.ZMinMm = Math.Min(result.ZMinMm, Math.Min(z0, z1));
                    result.ZMaxMm = Math.Max(result.ZMaxMm, Math.Max(z0, z1));
                }
            }
            return result;
        }
    }
}
'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

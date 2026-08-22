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

        private static Feature CreateRectangleSketch(ModelDoc2 model, Feature plane, string sketchName, double lengthXmm, double widthYmm)
        {
            if (lengthXmm <= 0.0 || widthYmm <= 0.0) throw new ArgumentException("Rectangle dimensions must be positive.");
            double hx = M(lengthXmm / 2.0);
            double hy = M(widthYmm / 2.0);

            model.ClearSelection2(true);
            if (!plane.Select2(false, 0)) throw new InvalidOperationException("Cannot select plane for " + sketchName);
            model.SketchManager.InsertSketch(true);
            object rect = model.SketchManager.CreateCornerRectangle(-hx, hy, 0.0, hx, -hy, 0.0);
            if (rect == null) throw new InvalidOperationException("CreateCornerRectangle failed for " + sketchName);
            return FinishSketch(model, sketchName);
        }

        private static Feature CreateFourCornerCirclesSketch(ModelDoc2 model, Feature plane, string sketchName, double centerXmm, double centerYmm, double radiusMm)
        {
            if (centerXmm < 0.0 || centerYmm < 0.0 || radiusMm <= 0.0)
                throw new ArgumentException("Invalid corner-circle geometry.");

            double cx = M(centerXmm);
            double cy = M(centerYmm);
            double r = M(radiusMm);

            model.ClearSelection2(true);
            if (!plane.Select2(false, 0)) throw new InvalidOperationException("Cannot select plane for " + sketchName);
            model.SketchManager.InsertSketch(true);

            SketchSegment c1 = model.SketchManager.CreateCircleByRadius( cx,  cy, 0.0, r);
            SketchSegment c2 = model.SketchManager.CreateCircleByRadius(-cx,  cy, 0.0, r);
            SketchSegment c3 = model.SketchManager.CreateCircleByRadius(-cx, -cy, 0.0, r);
            SketchSegment c4 = model.SketchManager.CreateCircleByRadius( cx, -cy, 0.0, r);
            if (c1 == null || c2 == null || c3 == null || c4 == null)
                throw new InvalidOperationException("Failed to create four corner circles for " + sketchName);

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

            // Robust construction for the 12in upper drive slot.
            // Numeric orientation is supplied by S04 V2 after decoding the 20in reference topology.
            double innerLength = lengthXmm - 2.0 * cornerRmm;
            double innerWidth = widthYmm - 2.0 * cornerRmm;
            double cornerCenterX = lengthXmm / 2.0 - cornerRmm;
            double cornerCenterY = widthYmm / 2.0 - cornerRmm;

            Feature sx = CreateRectangleSketch(model, plane, "SK_UPPER_DRIVE_SLOT_CORE_X", lengthXmm, innerWidth);
            CutSelectedSketch(model, sx, "CUT_UPPER_DRIVE_SLOT_CORE_X", false, depthMm, reverseDir);

            Feature sy = CreateRectangleSketch(model, plane, "SK_UPPER_DRIVE_SLOT_CORE_Y", innerLength, widthYmm);
            CutSelectedSketch(model, sy, "CUT_UPPER_DRIVE_SLOT_CORE_Y", false, depthMm, reverseDir);

            Feature sc = CreateFourCornerCirclesSketch(
                model,
                plane,
                "SK_UPPER_DRIVE_SLOT_70x44_R8",
                cornerCenterX,
                cornerCenterY,
                cornerRmm);
            Feature finalCut = CutSelectedSketch(model, sc, "CUT_UPPER_DRIVE_SLOT_70x44_R8", false, depthMm, reverseDir);
            return finalCut.Name;
        }

        public static void ApplyPresentationAppearance(object modelObject)
        {
            ModelDoc2 model = AsModel(modelObject);

            // Neutral industrial grey matched to the customer's readable assembly presentation.
            // Deliberately brighter than the previous near-black appearance so spherical curvature,
            // bores, slots, shoulders and edge transitions remain visible during design review.
            model.MaterialPropertyValues = new double[]
            {
                0.42, 0.42, 0.42,   // R, G, B: medium neutral grey
                0.30,               // ambient
                0.72,               // diffuse
                0.24,               // specular
                0.26,               // shininess
                0.00,               // transparency
                0.00                // emission
            };

            // Hide construction/reference geometry for the saved presentation state.
            Feature f = (Feature)model.FirstFeature();
            while (f != null)
            {
                Feature next = (Feature)f.GetNextFeature();
                string type = "";
                try { type = f.GetTypeName2(); } catch { }

                try
                {
                    if (String.Equals(type, "RefPlane", StringComparison.OrdinalIgnoreCase) ||
                        String.Equals(type, "RefAxis", StringComparison.OrdinalIgnoreCase))
                    {
                        model.ClearSelection2(true);
                        if (f.Select2(false, 0)) model.BlankRefGeom();
                    }
                    else if (String.Equals(type, "ProfileFeature", StringComparison.OrdinalIgnoreCase) ||
                             String.Equals(type, "3DProfileFeature", StringComparison.OrdinalIgnoreCase))
                    {
                        model.ClearSelection2(true);
                        if (f.Select2(false, 0)) model.BlankSketch();
                    }
                }
                catch { }

                f = next;
            }

            model.ClearSelection2(true);
            try { model.GraphicsRedraw2(); } catch { }
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

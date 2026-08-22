function Add-EmbeddedSwBallProcessHoleApiType {
    if ('Q347F.SwBallProcessHoleApi' -as [type]) { return }

    $source = @'
using System;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

namespace Q347F
{
    public static class SwBallProcessHoleApi
    {
        private static ModelDoc2 AsModel(object modelObject)
        {
            if (modelObject == null) throw new ArgumentNullException("modelObject");
            return (ModelDoc2)modelObject;
        }

        private static double M(double mm) { return mm / 1000.0; }

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

        private static Feature FinishSketch(ModelDoc2 model, string sketchName)
        {
            model.SketchManager.InsertSketch(true);
            Feature sketch = GetLastSketchFeature(model);
            if (sketch == null) throw new InvalidOperationException("Cannot locate sketch " + sketchName);
            sketch.Name = sketchName;
            model.ClearSelection2(true);
            return sketch;
        }

        private static Feature CreateTwoCircleSketch(ModelDoc2 model, Feature plane, string sketchName, double centerOffsetXmm, double diameterMm)
        {
            if (centerOffsetXmm <= 0.0 || diameterMm <= 0.0)
                throw new ArgumentException("Process-hole offset and diameter must be positive.");

            model.ClearSelection2(true);
            if (!plane.Select2(false, 0)) throw new InvalidOperationException("Cannot select process-hole datum plane for " + sketchName);
            model.SketchManager.InsertSketch(true);

            double x = M(centerOffsetXmm);
            double r = M(diameterMm / 2.0);
            SketchSegment c1 = model.SketchManager.CreateCircleByRadius(-x, 0.0, 0.0, r);
            SketchSegment c2 = model.SketchManager.CreateCircleByRadius( x, 0.0, 0.0, r);
            if (c1 == null || c2 == null) throw new InvalidOperationException("Failed to create 2X process-hole circles for " + sketchName);
            return FinishSketch(model, sketchName);
        }

        private static Feature CutSelectedSketch(ModelDoc2 model, Feature sketch, string featureName, double depthMm, bool reverseDir)
        {
            model.ClearSelection2(true);
            if (!sketch.Select2(false, 0)) throw new InvalidOperationException("Cannot select sketch for " + featureName);

            Feature cut = model.FeatureManager.FeatureCut4(
                true,
                false,
                reverseDir,
                (int)swEndConditions_e.swEndCondBlind,
                (int)swEndConditions_e.swEndCondBlind,
                M(Math.Max(depthMm, 1.0)),
                M(Math.Max(depthMm, 1.0)),
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

        public static string[] CreateTwoStageProcessHoles(
            object modelObject,
            string planeName,
            double centerOffsetXmm,
            double counterboreDiameterMm,
            double counterboreCutDepthMm,
            double pilotDiameterMm,
            double pilotCutDepthMm,
            bool reverseDir)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature plane = FindFeatureByName(model, planeName);
            if (plane == null) throw new InvalidOperationException("Process-hole datum plane not found: " + planeName);
            if (pilotCutDepthMm <= counterboreCutDepthMm)
                throw new ArgumentException("Pilot cut depth must be greater than counterbore cut depth.");
            if (counterboreDiameterMm <= pilotDiameterMm)
                throw new ArgumentException("Counterbore diameter must be greater than pilot diameter.");

            Feature cbSketch = CreateTwoCircleSketch(model, plane, "SK_PROCESS_COUNTERBORE_2X", centerOffsetXmm, counterboreDiameterMm);
            Feature cbCut = CutSelectedSketch(model, cbSketch, "CUT_PROCESS_COUNTERBORE_2X", counterboreCutDepthMm, reverseDir);

            Feature pilotSketch = CreateTwoCircleSketch(model, plane, "SK_PROCESS_TAP_DRILL_2X", centerOffsetXmm, pilotDiameterMm);
            Feature pilotCut = CutSelectedSketch(model, pilotSketch, "CUT_PROCESS_TAP_DRILL_2X", pilotCutDepthMm, reverseDir);

            return new string[] { cbCut.Name, pilotCut.Name };
        }
    }
}
'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

function Add-EmbeddedSwGeometryApiType {
    if ('Q347F.SwGeometryApi' -as [type]) { return }

    $source = @'
using System;
using System.Collections.Generic;
using System.IO;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

namespace Q347F
{
    public static class SwGeometryApi
    {
        private static ModelDoc2 AsModel(object modelObject)
        {
            if (modelObject == null) throw new ArgumentNullException("modelObject");
            return (ModelDoc2)modelObject;
        }

        private static List<Feature> GetNativeDefaultPlanes(ModelDoc2 model)
        {
            List<Feature> planes = new List<Feature>();
            Feature f = (Feature)model.FirstFeature();
            while (f != null)
            {
                string type = "";
                try { type = f.GetTypeName2(); } catch { }
                if (String.Equals(type, "RefPlane", StringComparison.OrdinalIgnoreCase))
                {
                    planes.Add(f);
                    if (planes.Count == 3) break;
                }
                f = (Feature)f.GetNextFeature();
            }
            if (planes.Count < 3) throw new InvalidOperationException("Could not find the three native reference planes.");
            return planes;
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

        private static Feature GetLastFeatureOfType(ModelDoc2 model, string typeName)
        {
            Feature last = null;
            Feature f = (Feature)model.FirstFeature();
            while (f != null)
            {
                string type = "";
                try { type = f.GetTypeName2(); } catch { }
                if (String.Equals(type, typeName, StringComparison.OrdinalIgnoreCase)) last = f;
                f = (Feature)f.GetNextFeature();
            }
            return last;
        }

        private static Feature CreateCoincidentPlane(ModelDoc2 model, Feature nativePlane, string name)
        {
            model.ClearSelection2(true);
            if (!nativePlane.Select2(false, 0)) throw new InvalidOperationException("Cannot select native plane for " + name);
            object rp = model.FeatureManager.InsertRefPlane(
                (int)swRefPlaneReferenceConstraints_e.swRefPlaneReferenceConstraint_Coincident,
                0.0, 0, 0.0, 0, 0.0);
            if (rp == null) throw new InvalidOperationException("InsertRefPlane returned null for " + name);
            Feature feat = GetLastFeatureOfType(model, "RefPlane");
            if (feat == null) throw new InvalidOperationException("Cannot locate created plane " + name);
            feat.Name = name;
            model.ClearSelection2(true);
            return feat;
        }

        public static string[] CreateProjectBasePlanes(object modelObject)
        {
            ModelDoc2 model = AsModel(modelObject);
            List<Feature> p = GetNativeDefaultPlanes(model);
            Feature xz = CreateCoincidentPlane(model, p[0], "PLN_BASE_XZ_FLOW_SUPPORT");
            Feature xy = CreateCoincidentPlane(model, p[1], "PLN_BASE_XY_FLOW_CROSS");
            Feature yz = CreateCoincidentPlane(model, p[2], "PLN_BASE_YZ_CROSS_SUPPORT");
            return new string[] { xy.Name, xz.Name, yz.Name };
        }

        public static string[] CreateProjectAxes(object modelObject)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature xy = FindFeatureByName(model, "PLN_BASE_XY_FLOW_CROSS");
            Feature xz = FindFeatureByName(model, "PLN_BASE_XZ_FLOW_SUPPORT");
            Feature yz = FindFeatureByName(model, "PLN_BASE_YZ_CROSS_SUPPORT");
            if (xy == null || xz == null || yz == null) throw new InvalidOperationException("Project base planes are missing.");

            model.ClearSelection2(true);
            if (!xy.Select2(false, 0) || !xz.Select2(true, 0)) throw new InvalidOperationException("Cannot select planes for FLOW_AXIS_X.");
            if (!model.InsertAxis2(true)) throw new InvalidOperationException("InsertAxis2 failed for FLOW_AXIS_X.");
            Feature xAxis = GetLastFeatureOfType(model, "RefAxis");
            if (xAxis == null) throw new InvalidOperationException("Cannot locate FLOW_AXIS_X feature.");
            xAxis.Name = "AXIS_X_FLOW";

            model.ClearSelection2(true);
            if (!xz.Select2(false, 0) || !yz.Select2(true, 0)) throw new InvalidOperationException("Cannot select planes for SUPPORT_AXIS_Z.");
            if (!model.InsertAxis2(true)) throw new InvalidOperationException("InsertAxis2 failed for SUPPORT_AXIS_Z.");
            Feature zAxis = GetLastFeatureOfType(model, "RefAxis");
            if (zAxis == null) throw new InvalidOperationException("Cannot locate SUPPORT_AXIS_Z feature.");
            zAxis.Name = "AXIS_Z_SUPPORT";
            model.ClearSelection2(true);
            return new string[] { xAxis.Name, zAxis.Name };
        }

        public static object CreateStationPlane(object modelObject, string axis, double offsetMm, string name)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature basePlane;
            if (String.Equals(axis, "X", StringComparison.OrdinalIgnoreCase))
                basePlane = FindFeatureByName(model, "PLN_BASE_YZ_CROSS_SUPPORT");
            else if (String.Equals(axis, "Z", StringComparison.OrdinalIgnoreCase))
                basePlane = FindFeatureByName(model, "PLN_BASE_XY_FLOW_CROSS");
            else
                throw new ArgumentException("Axis must be X or Z.");

            if (basePlane == null) throw new InvalidOperationException("Base plane not found for axis " + axis);
            model.ClearSelection2(true);
            if (!basePlane.Select2(false, 0)) throw new InvalidOperationException("Cannot select base plane for " + name);

            object rp;
            if (Math.Abs(offsetMm) < 1e-9)
            {
                rp = model.FeatureManager.InsertRefPlane(
                    (int)swRefPlaneReferenceConstraints_e.swRefPlaneReferenceConstraint_Coincident,
                    0.0, 0, 0.0, 0, 0.0);
            }
            else
            {
                int constraint = (int)swRefPlaneReferenceConstraints_e.swRefPlaneReferenceConstraint_Distance;
                if (offsetMm < 0)
                    constraint |= (int)swRefPlaneReferenceConstraints_e.swRefPlaneReferenceConstraint_OptionFlip;
                rp = model.FeatureManager.InsertRefPlane(constraint, Math.Abs(offsetMm) / 1000.0, 0, 0.0, 0, 0.0);
            }
            if (rp == null) throw new InvalidOperationException("InsertRefPlane returned null for " + name);
            Feature feat = GetLastFeatureOfType(model, "RefPlane");
            if (feat == null) throw new InvalidOperationException("Cannot locate created station plane " + name);
            feat.Name = name;
            model.ClearSelection2(true);
            return feat;
        }

        public static double ReadPlaneCoordinateMm(object modelObject, string featureName, string axis)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature feat = FindFeatureByName(model, featureName);
            if (feat == null) throw new InvalidOperationException("Plane not found: " + featureName);
            RefPlane plane = feat.GetSpecificFeature2() as RefPlane;
            if (plane == null) throw new InvalidOperationException("GetSpecificFeature2 did not return RefPlane for " + featureName);
            MathTransform tx = plane.Transform;
            if (tx == null) throw new InvalidOperationException("RefPlane.Transform returned null for " + featureName);
            object raw = tx.ArrayData;
            Array a = raw as Array;
            if (a == null || a.Length < 12) throw new InvalidOperationException("Invalid RefPlane transform for " + featureName);
            int index;
            if (String.Equals(axis, "X", StringComparison.OrdinalIgnoreCase)) index = 9;
            else if (String.Equals(axis, "Z", StringComparison.OrdinalIgnoreCase)) index = 11;
            else throw new ArgumentException("Axis must be X or Z.");
            return Convert.ToDouble(a.GetValue(index)) * 1000.0;
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

        public static string CreateBallCenterPoint(object modelObject)
        {
            ModelDoc2 model = AsModel(modelObject);
            model.ClearSelection2(true);
            model.SketchManager.Insert3DSketch(true);
            SketchPoint pt = model.SketchManager.CreatePoint(0.0, 0.0, 0.0);
            if (pt == null) throw new InvalidOperationException("CreatePoint failed for BALL_CENTER_O.");
            model.SketchManager.Insert3DSketch(true);
            Feature sketch = GetLastSketchFeature(model);
            if (sketch == null) throw new InvalidOperationException("Cannot locate BALL_CENTER_O 3D sketch.");
            sketch.Name = "SK_PT_BALL_CENTER_O";
            model.ClearSelection2(true);
            return sketch.Name;
        }

        public static string CreateEnvelopeSketch(object modelObject, string planeName, string sketchName, double[] diametersMm)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature plane = FindFeatureByName(model, planeName);
            if (plane == null) throw new InvalidOperationException("Envelope sketch plane missing: " + planeName);
            model.ClearSelection2(true);
            if (!plane.Select2(false, 0)) throw new InvalidOperationException("Cannot select envelope sketch plane: " + planeName);
            model.SketchManager.InsertSketch(true);
            foreach (double d in diametersMm)
            {
                SketchSegment seg = model.SketchManager.CreateCircleByRadius(0.0, 0.0, 0.0, d / 2000.0);
                if (seg == null) throw new InvalidOperationException("CreateCircleByRadius failed in " + sketchName);
                try { seg.ConstructionGeometry = true; } catch { }
            }
            model.SketchManager.InsertSketch(true);
            Feature sketch = GetLastSketchFeature(model);
            if (sketch == null) throw new InvalidOperationException("Cannot locate created envelope sketch: " + sketchName);
            sketch.Name = sketchName;
            model.ClearSelection2(true);
            return sketch.Name;
        }
    }
}

'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

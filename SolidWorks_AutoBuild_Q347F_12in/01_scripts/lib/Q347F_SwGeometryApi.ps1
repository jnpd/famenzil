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

        private static string ClassifyPlaneOrientationByWorldCorners(Feature feature)
        {
            RefPlane plane = feature.GetSpecificFeature2() as RefPlane;
            if (plane == null) throw new InvalidOperationException("Native RefPlane interface unavailable for " + feature.Name);

            Array points = plane.CornerPoints as Array;
            if (points == null || points.Length < 4)
                throw new InvalidOperationException("Native plane CornerPoints unavailable for " + feature.Name);

            double[] min = new double[] { Double.PositiveInfinity, Double.PositiveInfinity, Double.PositiveInfinity };
            double[] max = new double[] { Double.NegativeInfinity, Double.NegativeInfinity, Double.NegativeInfinity };

            foreach (object pointObject in points)
            {
                MathPoint point = pointObject as MathPoint;
                if (point == null) throw new InvalidOperationException("CornerPoints item is not MathPoint for " + feature.Name);
                Array data = point.ArrayData as Array;
                if (data == null || data.Length < 3) throw new InvalidOperationException("Invalid MathPoint.ArrayData for " + feature.Name);
                for (int i = 0; i < 3; i++)
                {
                    double v = Convert.ToDouble(data.GetValue(i));
                    min[i] = Math.Min(min[i], v);
                    max[i] = Math.Max(max[i], v);
                }
            }

            double sx = max[0] - min[0];
            double sy = max[1] - min[1];
            double sz = max[2] - min[2];

            if (sx <= sy && sx <= sz) return "YZ"; // X = constant
            if (sy <= sx && sy <= sz) return "XZ"; // Y = constant
            return "XY";                           // Z = constant
        }

        private static Dictionary<string, Feature> GetNativeDefaultPlanesByOrientation(ModelDoc2 model)
        {
            List<Feature> planes = GetNativeDefaultPlanes(model);
            Dictionary<string, Feature> result = new Dictionary<string, Feature>(StringComparer.OrdinalIgnoreCase);

            bool classified = true;
            try
            {
                foreach (Feature f in planes)
                {
                    string orientation = ClassifyPlaneOrientationByWorldCorners(f);
                    if (result.ContainsKey(orientation))
                    {
                        classified = false;
                        break;
                    }
                    result[orientation] = f;
                }
                classified = classified && result.ContainsKey("XY") && result.ContainsKey("XZ") && result.ContainsKey("YZ");
            }
            catch
            {
                classified = false;
            }

            if (!classified)
            {
                // Standard SOLIDWORKS new-part order is Front, Top, Right.
                // In SOLIDWORKS world coordinates these are XY, XZ, YZ respectively.
                // This fallback is only used if CornerPoints classification is unavailable.
                result.Clear();
                result["XY"] = planes[0];
                result["XZ"] = planes[1];
                result["YZ"] = planes[2];
            }

            return result;
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
            Dictionary<string, Feature> p = GetNativeDefaultPlanesByOrientation(model);

            // Project coordinate convention:
            // XY plane -> Z=0, used for all Z station offsets.
            // XZ plane -> Y=0, used with XY/YZ to define X and Z axes.
            // YZ plane -> X=0, used for all X station offsets.
            Feature xy = CreateCoincidentPlane(model, p["XY"], "PLN_BASE_XY_FLOW_CROSS");
            Feature xz = CreateCoincidentPlane(model, p["XZ"], "PLN_BASE_XZ_FLOW_SUPPORT");
            Feature yz = CreateCoincidentPlane(model, p["YZ"], "PLN_BASE_YZ_CROSS_SUPPORT");
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

        public static bool RebuildForReadback(object modelObject)
        {
            ModelDoc2 model = AsModel(modelObject);
            return model.ForceRebuild3(false);
        }

        private static double ReadPlaneCoordinateFromCornerPointsMm(RefPlane plane, string featureName, string axis)
        {
            object rawPoints = plane.CornerPoints;
            Array points = rawPoints as Array;
            if (points == null || points.Length < 4)
                throw new InvalidOperationException("RefPlane.CornerPoints did not return four points for " + featureName);

            int coordIndex;
            if (String.Equals(axis, "X", StringComparison.OrdinalIgnoreCase)) coordIndex = 0;
            else if (String.Equals(axis, "Z", StringComparison.OrdinalIgnoreCase)) coordIndex = 2;
            else throw new ArgumentException("Axis must be X or Z.");

            double sum = 0.0;
            double min = Double.PositiveInfinity;
            double max = Double.NegativeInfinity;
            int count = 0;
            foreach (object pointObject in points)
            {
                MathPoint point = pointObject as MathPoint;
                if (point == null) throw new InvalidOperationException("CornerPoints item is not MathPoint for " + featureName);
                Array data = point.ArrayData as Array;
                if (data == null || data.Length < 3) throw new InvalidOperationException("Invalid MathPoint.ArrayData for " + featureName);
                double value = Convert.ToDouble(data.GetValue(coordIndex));
                sum += value;
                min = Math.Min(min, value);
                max = Math.Max(max, value);
                count++;
            }
            if (count == 0) throw new InvalidOperationException("No corner point coordinates for " + featureName);

            if (Math.Abs(max - min) > 1e-5)
                throw new InvalidOperationException("Corner point spread is too large for station plane " + featureName);

            return (sum / count) * 1000.0;
        }

        private static double ReadPlaneCoordinateFromTransformMm(RefPlane plane, string featureName, string axis)
        {
            MathTransform tx = plane.Transform;
            if (tx == null) throw new InvalidOperationException("RefPlane.Transform returned null for " + featureName);
            Array a = tx.ArrayData as Array;
            if (a == null || a.Length < 12) throw new InvalidOperationException("Invalid RefPlane transform for " + featureName);
            int index;
            if (String.Equals(axis, "X", StringComparison.OrdinalIgnoreCase)) index = 9;
            else if (String.Equals(axis, "Z", StringComparison.OrdinalIgnoreCase)) index = 11;
            else throw new ArgumentException("Axis must be X or Z.");
            return Convert.ToDouble(a.GetValue(index)) * 1000.0;
        }

        public static double ReadPlaneCoordinateMm(object modelObject, string featureName, string axis)
        {
            ModelDoc2 model = AsModel(modelObject);
            Feature feat = FindFeatureByName(model, featureName);
            if (feat == null) throw new InvalidOperationException("Plane not found: " + featureName);
            RefPlane plane = feat.GetSpecificFeature2() as RefPlane;
            if (plane == null) throw new InvalidOperationException("GetSpecificFeature2 did not return RefPlane for " + featureName);

            try
            {
                return ReadPlaneCoordinateFromCornerPointsMm(plane, featureName, axis);
            }
            catch
            {
                return ReadPlaneCoordinateFromTransformMm(plane, featureName, axis);
            }
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

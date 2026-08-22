function Add-EmbeddedSwValidationApiType {
    if ('Q347F.SwValidationApi' -as [type]) { return }

    $source = @'
using System;
using System.Collections.Generic;
using System.IO;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

namespace Q347F
{
    public sealed class WhatsWrongItem
    {
        public string FeatureName;
        public int ErrorCode;
        public bool IsWarning;
        public string FeatureType;
    }

    public sealed class ValidationResult
    {
        public bool RebuildOk;
        public int ErrorCount;
        public int WarningCount;
        public List<WhatsWrongItem> Items = new List<WhatsWrongItem>();
    }

    public static class SwValidationApi
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

        public static ValidationResult Validate(object modelObject)
        {
            ModelDoc2 model = AsModel(modelObject);
            ValidationResult result = new ValidationResult();
            result.RebuildOk = model.ForceRebuild3(false);

            object features = null, codes = null, warnings = null;
            try
            {
                bool ok = model.Extension.GetWhatsWrong(out features, out codes, out warnings);
                if (ok && features is Array && codes is Array && warnings is Array)
                {
                    Array fa = (Array)features;
                    Array ca = (Array)codes;
                    Array wa = (Array)warnings;
                    int n = Math.Min(fa.Length, Math.Min(ca.Length, wa.Length));
                    for (int i = 0; i < n; i++)
                    {
                        Feature f = fa.GetValue(i) as Feature;
                        int code = Convert.ToInt32(ca.GetValue(i));
                        bool isWarning = Convert.ToBoolean(wa.GetValue(i));
                        if (code == 0) continue;
                        WhatsWrongItem item = new WhatsWrongItem
                        {
                            FeatureName = f == null ? "<unknown>" : f.Name,
                            FeatureType = f == null ? "<unknown>" : f.GetTypeName2(),
                            ErrorCode = code,
                            IsWarning = isWarning
                        };
                        result.Items.Add(item);
                        if (isWarning) result.WarningCount++; else result.ErrorCount++;
                    }
                }
            }
            catch { }

            Feature cur = (Feature)model.FirstFeature();
            HashSet<string> seen = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (WhatsWrongItem i in result.Items) seen.Add(i.FeatureName + "|" + i.ErrorCode + "|" + i.IsWarning);
            while (cur != null)
            {
                try
                {
                    bool warning;
                    int code = cur.GetErrorCode2(out warning);
                    if (code != 0)
                    {
                        string key = cur.Name + "|" + code + "|" + warning;
                        if (!seen.Contains(key))
                        {
                            result.Items.Add(new WhatsWrongItem
                            {
                                FeatureName = cur.Name,
                                FeatureType = cur.GetTypeName2(),
                                ErrorCode = code,
                                IsWarning = warning
                            });
                            if (warning) result.WarningCount++; else result.ErrorCount++;
                            seen.Add(key);
                        }
                    }
                }
                catch { }
                cur = (Feature)cur.GetNextFeature();
            }
            return result;
        }

        public static bool SaveAs(object modelObject, string path, out int errors, out int warnings)
        {
            ModelDoc2 model = AsModel(modelObject);
            errors = 0;
            warnings = 0;
            return model.Extension.SaveAs(
                path,
                (int)swSaveAsVersion_e.swSaveAsCurrentVersion,
                (int)swSaveAsOptions_e.swSaveAsOptions_Silent,
                null,
                ref errors,
                ref warnings);
        }

        public static bool FeatureExists(object modelObject, string name)
        {
            return FindFeatureByName(AsModel(modelObject), name) != null;
        }

        public static int CountFeatureType(object modelObject, string typeName)
        {
            ModelDoc2 model = AsModel(modelObject);
            int count = 0;
            Feature f = (Feature)model.FirstFeature();
            while (f != null)
            {
                string type = "";
                try { type = f.GetTypeName2(); } catch { }
                if (String.Equals(type, typeName, StringComparison.OrdinalIgnoreCase)) count++;
                f = (Feature)f.GetNextFeature();
            }
            return count;
        }
    }
}

'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

function Add-EmbeddedSwEquationApiType {
    if ('Q347F.SwEquationApi' -as [type]) { return }

    $source = @'
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;
using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swconst;

namespace Q347F
{
    public static class SwEquationApi
    {
        private static ModelDoc2 AsModel(object modelObject)
        {
            if (modelObject == null) throw new ArgumentNullException("modelObject");
            return (ModelDoc2)modelObject;
        }

        private static string ExtractLhsName(string equationText)
        {
            int q1 = equationText.IndexOf('"');
            if (q1 < 0) return "";
            int q2 = equationText.IndexOf('"', q1 + 1);
            if (q2 < 0) return "";
            return equationText.Substring(q1 + 1, q2 - q1 - 1);
        }

        private static int FindEquationIndex(EquationMgr mgr, string name)
        {
            int n = mgr.GetCount();
            for (int i = 0; i < n; i++)
            {
                string eq = mgr.get_Equation(i);
                if (String.Equals(ExtractLhsName(eq), name, StringComparison.OrdinalIgnoreCase)) return i;
            }
            return -1;
        }

        private static string NormalizeForSolidWorks(string equationText)
        {
            // The project source file intentionally keeps explicit engineering units such as
            // 610mm and 22.5deg. SOLIDWORKS EquationMgr.Add2 accepts the length literals used
            // by this project, but on this SOLIDWORKS 2025 installation it rejects the explicit
            // "deg" suffix for global-variable assignments. EquationMgr has its own angular-unit
            // setting, so keep the canonical source untouched and normalize degree literals only
            // at the CAD import boundary.
            return Regex.Replace(
                equationText,
                @"(?i)\b([0-9]+(?:\.[0-9]+)?)\s*deg\b",
                "$1");
        }

        public static int ImportOrUpdateEquations(object modelObject, string equationFile)
        {
            ModelDoc2 model = AsModel(modelObject);
            if (!File.Exists(equationFile)) throw new FileNotFoundException("Equation file not found", equationFile);
            EquationMgr mgr = model.GetEquationMgr();
            if (mgr == null) throw new InvalidOperationException("GetEquationMgr returned null.");

            mgr.AutomaticSolveOrder = true;
            mgr.AutomaticRebuild = false;

            // Explicitly define how bare angular values are interpreted after normalization.
            mgr.AngularEquationUnits = (int)swAngularEquationUnits_e.swAngularEquationUnitsDegrees;

            int sourceLine = 0;
            foreach (string raw in File.ReadAllLines(equationFile))
            {
                sourceLine++;
                string line = raw.Trim();
                if (line.Length == 0 || line.StartsWith("#") || line.StartsWith("//")) continue;

                string normalizedLine = NormalizeForSolidWorks(line);
                string name = ExtractLhsName(normalizedLine);
                if (name.Length == 0) continue;

                int idx = FindEquationIndex(mgr, name);
                int result;
                if (idx >= 0)
                {
                    mgr.set_Equation(idx, normalizedLine);
                    result = idx;
                    if (mgr.Status == -1)
                    {
                        throw new InvalidOperationException(
                            "Equation update failed at source line " + sourceLine +
                            ", name=" + name +
                            ", source=" + line +
                            ", normalized=" + normalizedLine +
                            ", EquationMgr.Status=" + mgr.Status +
                            ", EquationCount=" + mgr.GetCount());
                    }
                }
                else
                {
                    result = mgr.Add2(-1, normalizedLine, false);
                    if (result < 0)
                    {
                        throw new InvalidOperationException(
                            "Add2 failed at source line " + sourceLine +
                            ", name=" + name +
                            ", source=" + line +
                            ", normalized=" + normalizedLine +
                            ", EquationMgr.Status=" + mgr.Status +
                            ", EquationCount=" + mgr.GetCount());
                    }
                }
            }

            // Do not LinkToFile here. The canonical project file contains engineering-friendly
            // explicit degree suffixes; re-reading that file inside SOLIDWORKS would bypass the
            // normalization above. Every build re-imports the canonical source, so it remains the
            // single source of truth without making the SLDPRT depend on a generated sidecar file.
            try { mgr.LinkToFile = false; } catch { }

            mgr.AutomaticRebuild = true;
            try { mgr.EvaluateAll(); } catch { }
            model.EditRebuild3();
            return mgr.GetCount();
        }
    }
}

'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

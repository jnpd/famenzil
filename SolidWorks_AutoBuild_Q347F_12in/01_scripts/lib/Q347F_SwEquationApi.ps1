function Add-EmbeddedSwEquationApiType {
    if ('Q347F.SwEquationApi' -as [type]) { return }

    $source = @'
using System;
using System.IO;
using SolidWorks.Interop.sldworks;

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

        public static int ImportOrUpdateEquations(object modelObject, string equationFile)
        {
            ModelDoc2 model = AsModel(modelObject);
            if (!File.Exists(equationFile))
                throw new FileNotFoundException("Equation file not found", equationFile);

            EquationMgr mgr = model.GetEquationMgr();
            if (mgr == null) throw new InvalidOperationException("GetEquationMgr returned null.");

            // 00_SKELETON is intentionally a normal single-configuration part.
            // SOLIDWORKS API documentation requires Add2 for a part without
            // multiple configurations. Add3 can return -1 on a new one-config part.
            mgr.AutomaticSolveOrder = true;
            mgr.AutomaticRebuild = false;

            string[] lines = File.ReadAllLines(equationFile);
            int sourceLine = 0;
            foreach (string raw in lines)
            {
                sourceLine++;
                string line = raw.Trim();
                if (line.Length == 0 || line.StartsWith("#") || line.StartsWith("//")) continue;

                string name = ExtractLhsName(line);
                if (name.Length == 0)
                    throw new InvalidOperationException(
                        "Equation source line " + sourceLine + " has no valid quoted left-hand name: " + line);

                int idx = FindEquationIndex(mgr, name);
                if (idx >= 0)
                {
                    try
                    {
                        mgr.set_Equation(idx, line);
                    }
                    catch (Exception ex)
                    {
                        throw new InvalidOperationException(
                            "Failed to update equation at source line " + sourceLine +
                            ", name=" + name + ", equation=" + line +
                            ", EquationMgr.Status=" + mgr.Status + ". " + ex.Message, ex);
                    }

                    if (mgr.Status < 0)
                        throw new InvalidOperationException(
                            "Equation update returned error at source line " + sourceLine +
                            ", name=" + name + ", equation=" + line +
                            ", EquationMgr.Status=" + mgr.Status);
                }
                else
                {
                    int result = mgr.Add2(-1, line, false);
                    if (result < 0)
                        throw new InvalidOperationException(
                            "Add2 failed at source line " + sourceLine +
                            ", name=" + name + ", equation=" + line +
                            ", EquationMgr.Status=" + mgr.Status +
                            ", EquationCount=" + mgr.GetCount());
                }
            }

            // Evaluate only after all globals exist so dependent expressions resolve together.
            try { mgr.EvaluateAll(); }
            catch (Exception ex)
            {
                throw new InvalidOperationException(
                    "EquationMgr.EvaluateAll failed after importing " + mgr.GetCount() +
                    " equations. Status=" + mgr.Status + ". " + ex.Message, ex);
            }

            mgr.AutomaticRebuild = true;
            if (!model.EditRebuild3())
                throw new InvalidOperationException("EditRebuild3 returned false after equation import.");

            // Preserve the project parameter text as the external equation source when allowed.
            // Linking is secondary to a successful in-model import: local policy may deny it.
            try
            {
                mgr.FilePath = equationFile;
                mgr.LinkToFile = true;
                mgr.UpdateValuesFromExternalEquationFile();
                try { mgr.EvaluateAll(); } catch { }
                model.EditRebuild3();
            }
            catch
            {
                // Keep the already imported global variables even if external linking is unavailable.
            }

            return mgr.GetCount();
        }
    }
}

'@

    Add-Type -TypeDefinition $source -Language CSharp -ReferencedAssemblies @($script:InteropSldworks, $script:InteropSwconst, 'System.dll', 'System.Core.dll')
}

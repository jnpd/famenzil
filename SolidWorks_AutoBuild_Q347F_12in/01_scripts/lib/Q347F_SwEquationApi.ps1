function Add-EmbeddedSwEquationApiType {
    if ('Q347F.SwEquationApi' -as [type]) { return }

    $source = @'
using System;
using System.Collections.Generic;
using System.IO;
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

        public static int ImportOrUpdateEquations(object modelObject, string equationFile)
        {
            ModelDoc2 model = AsModel(modelObject);
            if (!File.Exists(equationFile)) throw new FileNotFoundException("Equation file not found", equationFile);
            EquationMgr mgr = model.GetEquationMgr();
            if (mgr == null) throw new InvalidOperationException("GetEquationMgr returned null.");

            mgr.AutomaticSolveOrder = true;
            mgr.AutomaticRebuild = false;
            int allCfg = (int)swInConfigurationOpts_e.swAllConfiguration;

            foreach (string raw in File.ReadAllLines(equationFile))
            {
                string line = raw.Trim();
                if (line.Length == 0 || line.StartsWith("#") || line.StartsWith("//")) continue;
                string name = ExtractLhsName(line);
                if (name.Length == 0) continue;
                int idx = FindEquationIndex(mgr, name);
                int result;
                if (idx >= 0)
                    result = mgr.SetEquationAndConfigurationOption(idx, line, allCfg, null);
                else
                    result = mgr.Add3(-1, line, true, allCfg, null);
                if (result < 0) throw new InvalidOperationException("Failed to import equation: " + name);
            }

            try
            {
                mgr.FilePath = equationFile;
                mgr.LinkToFile = true;
                mgr.UpdateValuesFromExternalEquationFile();
            }
            catch
            {
                // Keep imported globals even if a local SOLIDWORKS policy prevents external linking.
            }

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

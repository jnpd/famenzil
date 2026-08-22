Attribute VB_Name = "Q347F_Skeleton_ParamInit_V1"
Option Explicit

Private Const SW_DOC_PART As Long = 1
Private Const SW_ALL_CONFIGS As Long = 2

Private Const EQ_FILE_NAME As String = "Q347F_12in_Class150_00_SKELETON_GlobalVariables_V1.txt"
Private Const LOG_FILE_NAME As String = "Q347F_12in_Class150_Skeleton_ParamInit_V1.log.txt"

Sub main()
    On Error GoTo EH

    Dim swApp As Object
    Dim swModel As Object
    Dim swEqMgr As Object

    Set swApp = Application.SldWorks
    Set swModel = swApp.ActiveDoc

    If swModel Is Nothing Then
        MsgBox "No active SOLIDWORKS document. Open 00_SKELETON.SLDPRT first.", vbExclamation
        Exit Sub
    End If

    If swModel.GetType <> SW_DOC_PART Then
        MsgBox "Active document is not a Part. Open 00_SKELETON.SLDPRT first.", vbExclamation
        Exit Sub
    End If

    Dim modelPath As String
    modelPath = swModel.GetPathName

    If Len(modelPath) = 0 Then
        MsgBox "Save the active part as 00_SKELETON.SLDPRT before running this macro.", vbExclamation
        Exit Sub
    End If

    Dim folderPath As String
    folderPath = Left$(modelPath, InStrRev(modelPath, "\") - 1)

    Dim eqPath As String
    eqPath = folderPath & "\" & EQ_FILE_NAME

    If Dir$(eqPath) = "" Then
        eqPath = InputBox( _
            "Equation file was not found beside the part." & vbCrLf & _
            "Enter the full path to:" & vbCrLf & EQ_FILE_NAME, _
            "Q347F Skeleton - Equation File")

        If Len(Trim$(eqPath)) = 0 Then Exit Sub

        If Dir$(eqPath) = "" Then
            MsgBox "Equation file does not exist:" & vbCrLf & eqPath, vbCritical
            Exit Sub
        End If
    End If

    Set swEqMgr = swModel.GetEquationMgr

    If swEqMgr Is Nothing Then
        MsgBox "Failed to get SOLIDWORKS Equation Manager.", vbCritical
        Exit Sub
    End If

    swEqMgr.AutomaticSolveOrder = True
    swEqMgr.AutomaticRebuild = False

    Dim linkedPath As String
    linkedPath = ""

    On Error Resume Next
    If swEqMgr.LinkToFile Then linkedPath = swEqMgr.FilePath
    On Error GoTo EH

    If Len(linkedPath) > 0 Then
        If LCase$(linkedPath) <> LCase$(eqPath) Then
            MsgBox _
                "This part is already linked to a different equation file:" & vbCrLf & _
                linkedPath & vbCrLf & vbCrLf & _
                "Macro stopped to avoid replacing an existing link.", _
                vbCritical
            Exit Sub
        End If
    Else
        ImportOrUpdateEquations swEqMgr, eqPath
        swEqMgr.FilePath = eqPath
        swEqMgr.LinkToFile = True
    End If

    Dim updateOK As Boolean
    updateOK = swEqMgr.UpdateValuesFromExternalEquationFile()

    swEqMgr.AutomaticRebuild = True
    swModel.EditRebuild3

    On Error Resume Next
    swEqMgr.EvaluateAll
    On Error GoTo EH

    Dim logPath As String
    logPath = folderPath & "\" & LOG_FILE_NAME

    Dim f As Integer
    f = FreeFile
    Open logPath For Output As #f

    Print #f, "Q347F NPS12 Class150 Skeleton ParamInit V1"
    Print #f, "Timestamp: " & Format$(Now, "yyyy-mm-dd hh:nn:ss")
    Print #f, "Part: " & modelPath
    Print #f, "Equation file: " & eqPath
    Print #f, "External update: " & CStr(updateOK)
    Print #f, "Equation count: " & CStr(swEqMgr.GetCount)
    Print #f, ""

    Print #f, "[KEY VARIABLE CHECKS]"
    Print #f, CheckVariable(swEqMgr, "VALVE_F2F", 0.61, 0.000001)
    Print #f, CheckVariable(swEqMgr, "HALF_F2F", 0.305, 0.000001)
    Print #f, CheckVariable(swEqMgr, "X_END_FLANGE_BACK_R_CAD", 0.2732, 0.00001)
    Print #f, CheckVariable(swEqMgr, "Z_ADAPTER_TOP_CAD", 0.3373, 0.00001)
    Print #f, CheckVariable(swEqMgr, "Z_KEY_START_CAD", 0.3398, 0.00002)
    Print #f, CheckVariable(swEqMgr, "Z_KEY_END_CAD", 0.4298, 0.00002)
    Print #f, CheckVariable(swEqMgr, "ASM_Z_TOTAL_CAD", 0.7191, 0.00002)
    Print #f, ""

    Print #f, "[REFERENCE PLANES FOUND IN FEATURE TREE]"
    DumpReferencePlanes swModel, f
    Print #f, ""

    Print #f, "[ALL EQUATIONS]"
    DumpEquations swEqMgr, f

    Close #f

    MsgBox _
        "Q347F Skeleton parameter initialization finished." & vbCrLf & vbCrLf & _
        "Equation link: OK" & vbCrLf & _
        "Log:" & vbCrLf & logPath & vbCrLf & vbCrLf & _
        "Next: check the seven PASS lines in the log before creating reference planes.", _
        vbInformation

    Exit Sub

EH:
    On Error Resume Next
    If f <> 0 Then Close #f
    MsgBox "Macro error " & Err.Number & ": " & Err.Description, vbCritical
End Sub

Private Sub ImportOrUpdateEquations(ByVal swEqMgr As Object, ByVal eqPath As String)
    Dim f As Integer
    Dim lineText As String
    Dim varName As String
    Dim idx As Long
    Dim resultIndex As Long

    f = FreeFile
    Open eqPath For Input As #f

    Do While Not EOF(f)
        Line Input #f, lineText
        lineText = Trim$(lineText)

        If Len(lineText) > 0 Then
            varName = ExtractLhsName(lineText)

            If Len(varName) > 0 Then
                idx = FindGlobalVariableIndex(swEqMgr, varName)

                If idx >= 0 Then
                    resultIndex = swEqMgr.SetEquationAndConfigurationOption( _
                        idx, lineText, SW_ALL_CONFIGS, Empty)

                    If resultIndex < 0 Then
                        Err.Raise vbObjectError + 101, , _
                            "Failed to update global variable: " & varName
                    End If
                Else
                    resultIndex = swEqMgr.Add3( _
                        -1, lineText, True, SW_ALL_CONFIGS, Empty)

                    If resultIndex < 0 Then
                        Err.Raise vbObjectError + 102, , _
                            "Failed to add global variable: " & varName
                    End If
                End If
            End If
        End If
    Loop

    Close #f
End Sub

Private Function ExtractLhsName(ByVal equationText As String) As String
    Dim q1 As Long
    Dim q2 As Long

    q1 = InStr(1, equationText, Chr$(34))
    If q1 = 0 Then Exit Function

    q2 = InStr(q1 + 1, equationText, Chr$(34))
    If q2 = 0 Then Exit Function

    ExtractLhsName = Mid$(equationText, q1 + 1, q2 - q1 - 1)
End Function

Private Function FindGlobalVariableIndex(ByVal swEqMgr As Object, ByVal varName As String) As Long
    Dim i As Long
    Dim n As Long
    Dim eqText As String
    Dim lhs As String

    FindGlobalVariableIndex = -1
    n = swEqMgr.GetCount

    For i = 0 To n - 1
        eqText = swEqMgr.Equation(i)
        lhs = ExtractLhsName(eqText)

        If StrComp(lhs, varName, vbTextCompare) = 0 Then
            FindGlobalVariableIndex = i
            Exit Function
        End If
    Next i
End Function

Private Function CheckVariable( _
    ByVal swEqMgr As Object, _
    ByVal varName As String, _
    ByVal expectedSI As Double, _
    ByVal toleranceSI As Double) As String

    Dim idx As Long
    idx = FindGlobalVariableIndex(swEqMgr, varName)

    If idx < 0 Then
        CheckVariable = "FAIL  " & varName & "  missing"
        Exit Function
    End If

    Dim actualSI As Double
    actualSI = swEqMgr.Value(idx)

    If Abs(actualSI - expectedSI) <= toleranceSI Then
        CheckVariable = _
            "PASS  " & varName & _
            "  actualSI=" & Format$(actualSI, "0.000000") & _
            "  expectedSI=" & Format$(expectedSI, "0.000000")
    Else
        CheckVariable = _
            "FAIL  " & varName & _
            "  actualSI=" & Format$(actualSI, "0.000000") & _
            "  expectedSI=" & Format$(expectedSI, "0.000000")
    End If
End Function

Private Sub DumpReferencePlanes(ByVal swModel As Object, ByVal fileNo As Integer)
    Dim swFeat As Object
    Dim typeName As String
    Dim count As Long

    count = 0
    Set swFeat = swModel.FirstFeature

    Do While Not swFeat Is Nothing
        typeName = ""

        On Error Resume Next
        typeName = swFeat.GetTypeName2
        On Error GoTo 0

        If StrComp(typeName, "RefPlane", vbTextCompare) = 0 Then
            count = count + 1
            Print #fileNo, _
                "RefPlane[" & CStr(count) & "] Name=" & swFeat.Name & _
                " Type=" & typeName
        End If

        Set swFeat = swFeat.GetNextFeature
    Loop

    If count = 0 Then
        Print #fileNo, "WARNING: No RefPlane features found."
    End If
End Sub

Private Sub DumpEquations(ByVal swEqMgr As Object, ByVal fileNo As Integer)
    Dim i As Long
    Dim n As Long
    Dim v As Double

    n = swEqMgr.GetCount

    For i = 0 To n - 1
        v = swEqMgr.Value(i)
        Print #fileNo, _
            CStr(i) & vbTab & _
            swEqMgr.Equation(i) & vbTab & _
            "SI=" & Format$(v, "0.000000000")
    Next i
End Sub

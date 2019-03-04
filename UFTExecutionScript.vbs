'******************************************************************************************'**************************
'Killing excel process as it consumes more memory, also ensuring that excel doesnot hang from Quick Test Professional
'******************************************************************************************'**************************
Dim objWMIService, objProcess, colProcess
Dim strComputer, strProcessKill
strComputer = "."
strProcessKill = "'EXCEL.exe'"
 
Set objWMIService = GetObject("winmgmts:"&"{impersonationLevel=impersonate}!\\" & strComputer & "\root\cimv2")
 
Set colProcess = objWMIService.ExecQuery ("Select * from Win32_Process Where Name = " & strProcessKill)
For Each objProcess in colProcess
	objProcess.Terminate()
Next

'******************************************************************************************'**************************
'Execution from UFT
'******************************************************************************************'**************************
Dim dDate,strFlodername
dDate=Now()
strFoldername="Report_"&Day(dDate)&"-"&Month(dDate)&"-"&hour(dDate)&"-"&Minute(dDate)
dim fso: set fso = CreateObject("Scripting.FileSystemObject")

' directory in which this script is currently running
CurrentDirectory = fso.GetAbsolutePathName(".")

Set objExcel = createobject("excel.application")
objExcel.Workbooks.Open CurrentDirectory&"\TestScriptsList.xls"
objExcel.Application.Visible = false

Set objSheet = objExcel.ActiveWorkbook.Worksheets("ScriptsList")
 
'Get the max row occupied in the excel file 
iRowCount = objSheet.UsedRange.Rows.Count
Set UftApplication = CreateObject("QuickTest.Application")
UftApplication.Launch
UftApplication.Visible = true
'To read the data from the entire Excel file
For  i = 2 to iRowCount
	strValue = objSheet.Cells(i,6).Value
	If ucase(strValue) = "YES" Then
		strTestScript = objSheet.Cells(i,5).Value
		strModule = objSheet.Cells(i,2).Value	
		TestScriptPath = CurrentDirectory&"\"&strTestScript
		UftApplication.Options.Run.RunMode = "Normal"
		UftApplication.Options.Run.ViewResults = False
		UftApplication.Open TestScriptPath, True
		UftApplication.Test.Environment.Value("FolderName")=strFoldername
		UftApplication.Test.Environment.Value("ExecutionType")="Batch"
		UftApplication.Test.Save
		UftApplication.Test.Run	
	End If
Next
UftApplication.Open CurrentDirectory&"\TestCases\ResultsSummary"
UftApplication.Test.Environment.Value("FolderName")=strFoldername
UftApplication.Test.Environment.Value("ExecutionType")="Batch"
UftApplication.Test.Save
UftApplication.Test.Run
UftApplication.Quit
Set UftTest = Nothing
Set UftApplication = Nothing
objExcel.ActiveWorkbook.Close
objExcel.Application.Quit
Set objSheet = Nothing
Set objExcel = Nothing
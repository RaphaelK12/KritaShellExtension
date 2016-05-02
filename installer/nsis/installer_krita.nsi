!ifndef KRITA_INSTALLER_32 & KRITA_INSTALLER_64
	!error "Either one of KRITA_INSTALLER_32 or KRITA_INSTALLER_64 must be defined."
!endif
!ifdef KRITA_INSTALLER_32 & KRITA_INSTALLER_64
	!error "Only one of KRITA_INSTALLER_32 or KRITA_INSTALLER_64 should be defined."
!endif

!ifndef KRITA_PACKAGE_ROOT
	!error "KRITA_PACKAGE_ROOT should be defined and point to the root of the package files."
!endif

Unicode true

# Krita constants (can be overridden in command line params)
!define /ifndef KRITA_VERSION "0.0.0.0"
!define /ifndef KRITA_VERSION_DISPLAY "test-version"
#!define /ifndef KRITA_VERSION_GIT ""
!define /ifndef KRITA_INSTALLER_OUTPUT_DIR ""
!ifdef KRITA_INSTALLER_64
	!define /ifndef KRITA_INSTALLER_OUTPUT_NAME "krita_x64_setup.exe"
!else
	!define /ifndef KRITA_INSTALLER_OUTPUT_NAME "krita_x86_setup.exe"
!endif

# Krita constants (fixed)
!if "${KRITA_INSTALLER_OUTPUT_DIR}" == ""
	!define KRITA_INSTALLER_OUTPUT "${KRITA_INSTALLER_OUTPUT_NAME}"
!else
	!define KRITA_INSTALLER_OUTPUT "${KRITA_INSTALLER_OUTPUT_DIR}\${KRITA_INSTALLER_OUTPUT_NAME}"
!endif
!define KRTIA_PUBLISHER "Krita Foundation"
!ifdef KRITA_INSTALLER_64
	!define KRITA_PRODUCTNAME "Krita (x64)"
	!define KRITA_UNINSTALL_REGKEY "Krita_x64"
!else
	!define KRITA_PRODUCTNAME "Krita (x86)"
	!define KRITA_UNINSTALL_REGKEY "Krita_x86"
!endif

VIProductVersion "${KRITA_VERSION}"
VIAddVersionKey "CompanyName" "${KRTIA_PUBLISHER}"
VIAddVersionKey "FileDescription" "${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY} Setup"
VIAddVersionKey "FileVersion" "${KRITA_VERSION}"
VIAddVersionKey "InternalName" "${KRITA_INSTALLER_OUTPUT_NAME}"
VIAddVersionKey "LegalCopyright" "${KRTIA_PUBLISHER}"
VIAddVersionKey "OriginalFileName" "${KRITA_INSTALLER_OUTPUT_NAME}"
VIAddVersionKey "ProductName" "${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY} Setup"
VIAddVersionKey "ProductVersion" "${KRITA_VERSION}"

Name "${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY}"
OutFile ${KRITA_INSTALLER_OUTPUT}
!ifdef KRITA_INSTALLER_64
	InstallDir "$PROGRAMFILES64\Krita (x64)"
!else
	InstallDir "$PROGRAMFILES32\Krita (x86)"
!endif
XPstyle on

ShowInstDetails show
ShowUninstDetails show

!include MUI2.nsh

!define MUI_FINISHPAGE_NOAUTOCLOSE

# Installer Pages
!insertmacro MUI_PAGE_WELCOME
!define MUI_LICENSEPAGE_CHECKBOX
!insertmacro MUI_PAGE_LICENSE "license_gpl-2.0.rtf"
!insertmacro MUI_PAGE_DIRECTORY
#!insertmacro MUI_PAGE_COMPONENTS
!define MUI_PAGE_HEADER_TEXT "License Agreement (Krita Shell Extension)"
!insertmacro MUI_PAGE_LICENSE "license.rtf"
# TODO: More options?
!define MUI_WELCOMEPAGE_TITLE "placeholder page"
!define MUI_WELCOMEPAGE_TEXT "there should be shortcut options here I think? or what?$\r$\n$\r$\n$_CLICK"
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

# Uninstaller Pages
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES

!insertmacro MUI_LANGUAGE "English"

!include LogicLib.nsh
!include x64.nsh

!define KRITA_SHELLEX_DIR "$INSTDIR\shellex"

!include "include\FileExists2.nsh"
!include "krita_versions_detect.nsh"
!include "krita_shell_integration.nsh"

# ----[[

!macro SelectSection_Macro SecId
	Push $R0
	SectionGetFlags ${SecId} $R0
	IntOp $R0 $R0 | ${SF_SELECTED}
	SectionSetFlags ${SecId} $R0
	Pop $R0
!macroend
!define SelectSection '!insertmacro SelectSection_Macro'

!macro DeselectSection_Macro SecId
	Push $R0
	SectionGetFlags ${SecId} $R0
	IntOp $R0 $R0 ^ ${SF_SELECTED}
	SectionSetFlags ${SecId} $R0
	Pop $R0
!macroend
!define DeselectSection '!insertmacro DeselectSection_Macro'

# ----]]

Var KritaMsiProductX86
Var KritaMsiProductX64
Var KritaNsisVersion
Var KritaNsisBitness
Var KritaNsisInstallLocation

Var PrevShellExInstallLocation
Var PrevShellExStandalone

Section "Remove_shellex"
	${If} ${FileExists} "$PrevShellExInstallLocation\uninstall.exe"
		ExecWait "$PrevShellExInstallLocation\uninstall.exe /S _?=$PrevShellExInstallLocation"
		Delete "$PrevShellExInstallLocation\uninstall.exe"
	${EndIf}
SectionEnd

#Section "Remove_prev_version"
#	${If} ${FileExists} "$KritaNsisInstallLocation\uninstall.exe"
#		ExecWait "$KritaNsisInstallLocation\uninstall.exe /S _?=$KritaNsisInstallLocation"
#		Delete "$KritaNsisInstallLocation\uninstall.exe"
#	${EndIf}
#SectionEnd

Section "Thing"
	SetOutPath $INSTDIR
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                 "DisplayName" "${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                 "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
	WriteUninstaller $INSTDIR\uninstall.exe
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                 "DisplayVersion" "${KRITA_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                 "DisplayIcon" "$\"$INSTDIR\shellex\krita.ico$\",0"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                 "URLInfoAbout" "https://krita.org/"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                 "InstallLocation" "$INSTDIR"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                 "Publisher" "${KRTIA_PUBLISHER}"
	#WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	#                   "EstimatedSize" 250000
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                   "NoModify" 1
	WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}" \
	                   "NoRepair" 1
	# Registry entries for version recognition
	#   InstallLocation:
	#     Where krita is installed
	WriteRegStr HKLM "Software\Krita" \
	                 "InstallLocation" "$INSTDIR"
	#   Version:
	#     Version of Krita
	WriteRegStr HKLM "Software\Krita" \
	                 "Version" "${KRITA_VERSION}"
	#   x64:
	#     Set to 1 for 64-bit Krita, can be missing for 32-bit Krita
!ifdef KRITA_INSTALLER_64
	WriteRegDWORD HKLM "Software\Krita" \
	                   "x64" 1
!else
	DeleteRegValue HKLM "Software\Krita" "x64"
!endif

	#   ShellExtension\InstallLocation:
	#     Where the shell extension is installed
	#     If installed by Krita installer, this must point to shellex sub-dir
	WriteRegStr HKLM "Software\Krita\ShellExtension" \
	                 "InstallLocation" "$INSTDIR\shellex"
	#   ShellExtension\Version:
	#     Version of the shell extension
	WriteRegStr HKLM "Software\Krita\ShellExtension" \
	                 "Version" "${KRITASHELLEX_VERSION}"
	#   ShellExtension\Standalone:
	#     0 = Installed by Krita installer
	#     1 = Standalone installer
	WriteRegDWORD HKLM "Software\Krita\ShellExtension" \
	                   "Standalone" 0
	#   ShellExtension\KritaExePath:
	#     Path to krita.exe as specified by user or by Krita installer
	#     Empty if not specified
	WriteRegStr HKLM "Software\Krita\ShellExtension" \
	                 "KritaExePath" "$INSTDIR\bin\krita.exe"
SectionEnd

Section "Main_Krita"
	# TODO: Maybe switch to explicit file list?
	File /r ${KRITA_PACKAGE_ROOT}\bin
	File /r ${KRITA_PACKAGE_ROOT}\lib
	File /r ${KRITA_PACKAGE_ROOT}\share
SectionEnd

Section "ShellEx_mkdir"
	CreateDirectory ${KRITA_SHELLEX_DIR}
SectionEnd

Section "ShellEx_x64" SEC_shellex_x64
	${Krita_RegisterComComonents} 64
SectionEnd

Section "ShellEx_x86"
	${Krita_RegisterComComonents} 32
SectionEnd

Section "Main_associate"
	${Krita_RegisterFileAssociation} "$INSTDIR\bin\krita.exe"
SectionEnd

Section "ShellEx_common"
	${Krita_RegisterShellExtension}
SectionEnd

Section "Main_refreshShell"
	${RefreshShell}
SectionEnd

Section "un.ShellEx_common"
	${Krita_UnregisterShellExtension}
SectionEnd

Section "un.ShellExn_x64" SEC_un_shellex_x64
	${Krita_UnregisterComComonents} 64
SectionEnd

Section "un.ShellEx_x86"
	${Krita_UnregisterComComonents} 32
SectionEnd

Section "un.Main_associate"
	# TODO: Conditional, use install log
	${Krita_UnregisterFileAssociation}
SectionEnd

Section "un.Main_Krita"
	# TODO: Maybe switch to explicit file list or some sort of install log?
	RMDir /r $INSTDIR\bin
	RMDir /r $INSTDIR\lib
	RMDir /r $INSTDIR\share
SectionEnd

Section "un.Thing"
	RMDir /REBOOTOK $INSTDIR\shellex
	DeleteRegKey HKLM "Software\Krita"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${KRITA_UNINSTALL_REGKEY}"
	Delete $INSTDIR\uninstall.exe
	RMDir /REBOOTOK $INSTDIR
SectionEnd

Section "un.Main_refreshShell"
	${RefreshShell}
SectionEnd

Function .onInit
	MessageBox MB_OK|MB_ICONEXCLAMATION "This installer is experimental. Use only for testing."
!ifdef KRITA_INSTALLER_64
	${If} ${RunningX64}
		SetRegView 64
	${Else}
		MessageBox MB_OK|MB_ICONSTOP "You are running 32-bit Windows, but this installer installs Krita 64-bit which can only be installed on 64-bit Windows. Please download the 32-bit version on https://krita.org/"
		Abort
	${Endif}
!else
	${If} ${RunningX64}
		SetRegView 64
		MessageBox MB_YESNO|MB_ICONEXCLAMATION "You are trying to install 32-bit Krita on 64-bit Windows. You are strongly recommended to install the 64-bit version of Krita instead since it offers better performance.$\nIf you want to use the 32-bit version for testing, you should consider using the zip package instead.$\n$\nDo you still wish to install the 32-bit version of Krita?" \
		           /SD IDYES \
		           IDYES lbl_allow32on64
		Abort
		lbl_allow32on64:
	${Else}
		${DeselectSection} ${SEC_shellex_x64}
	${Endif}
!endif
	# Detect other Krita versions
	${DetectKritaMsi32bit} $KritaMsiProductX86
	${If} ${RunningX64}
		${DetectKritaMsi64bit} $KritaMsiProductX64
		${IfKritaMsi3Alpha} $KritaMsiProductX64
			MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Krita 3.0 Alpha 1 is installed. It must be removed before ${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY} can be installed.$\nDo you wish to remove it now?" \
			           /SD IDYES \
			           IDYES lbl_removeKrita3alpha
			Abort
			lbl_removeKrita3alpha:
			push $R0
			${MsiUninstall} $KritaMsiProductX64 $R0
			${If} $R0 != 0
				MessageBox MB_OK|MB_ICONSTOP "Failed to remove Krita 3.0 Alpha 1."
				Abort
			${EndIf}
			pop $R0
			StrCpy $KritaMsiProductX64 ""
		${ElseIf} $KritaMsiProductX64 != ""
			${If} $KritaMsiProductX86 != ""
				MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Both 32-bit and 64-bit editions of Krita 2.9 or below are installed.$\nBoth must be removed before ${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY} can be installed.$\nDo you want to remove them now?" \
				           /SD IDYES \
				           IDYES lbl_removeKritaBoth
				Abort
				lbl_removeKritaBoth:
				push $R0
				${MsiUninstall} $KritaMsiProductX86 $R0
				${If} $R0 != 0
					MessageBox MB_OK|MB_ICONSTOP "Failed to remove Krita (32-bit)."
					Abort
				${EndIf}
				${MsiUninstall} $KritaMsiProductX64 $R0
				${If} $R0 != 0
					MessageBox MB_OK|MB_ICONSTOP "Failed to remove Krita (64-bit)."
					Abort
				${EndIf}
				pop $R0
				StrCpy $KritaMsiProductX86 ""
				StrCpy $KritaMsiProductX64 ""
			${Else}
				MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Krita (64-bit) 2.9 or below is installed.$\nIt must be removed before ${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY} can be installed.$\nDo you wish to remove it now?" \
				           /SD IDYES \
				           IDYES lbl_removeKritaX64
				Abort
				lbl_removeKritaX64:
				push $R0
				${MsiUninstall} $KritaMsiProductX64 $R0
				${If} $R0 != 0
					MessageBox MB_OK|MB_ICONSTOP "Failed to remove Krita (64-bit)."
					Abort
				${EndIf}
				pop $R0
				StrCpy $KritaMsiProductX64 ""
			${EndIf}
		${EndIf}
	${Endif}
	${If} $KritaMsiProductX86 != ""
		MessageBox MB_YESNO|MB_ICONQUESTION|MB_DEFBUTTON2 "Krita (32-bit) 2.9 or below is installed.$\nIt must be removed before ${KRITA_PRODUCTNAME} ${KRITA_VERSION_DISPLAY} can be installed.$\nDo you wish to remove it now?" \
		           /SD IDYES \
		           IDYES lbl_removeKritaX86
		Abort
		lbl_removeKritaX86:
		push $R0
		${MsiUninstall} $KritaMsiProductX86 $R0
		${If} $R0 != 0
			MessageBox MB_OK|MB_ICONSTOP "Failed to remove Krita (32-bit)."
			Abort
		${EndIf}
		pop $R0
		StrCpy $KritaMsiProductX86 ""
	${EndIf}

	# TODO: Detect and abort on newer versions, and uninstall old versions without aborting (unless a version of different bitness is installed)
	${DetectKritaNsis} $KritaNsisVersion $KritaNsisBitness $KritaNsisInstallLocation
	${If} $KritaNsisVersion != ""
		#MessageBox MB_OK|MB_ICONEXCLAMATION "Krita $KritaNsisVersion ($KritaNsisBitness-bit) is installed. It will be uninstalled before this version is installed."
		MessageBox MB_OK|MB_ICONSTOP "Krita $KritaNsisVersion ($KritaNsisBitness-bit) is installed.$\nPlease uninstall it before running this installer."
		Abort
	${EndIf}

	# Detect standalone shell extension
	# TODO: Allow Krita and the shell extension to be installed separately?
	ClearErrors
	ReadRegStr $PrevShellExInstallLocation HKLM "Software\Krita\ShellExtension" "InstallLocation"
	#ReadRegStr $PrevShellExVersion HKLM "Software\Krita\ShellExtension" "Version"
	ReadRegDWORD $PrevShellExStandalone HKLM "Software\Krita\ShellExtension" "Standalone"
	#ReadRegStr $PrevShellExKritaExePath HKLM "Software\Krita\ShellExtension" "KritaExePath"
	${If} ${Errors}
		# TODO: Assume no previous version installed or what?
	${EndIf}
	${If} $PrevShellExStandalone == 1
		MessageBox MB_YESNO|MB_ICONQUESTION "Krita Shell Integration is already installed separately. It will be uninstalled automatically when installing Krita.$\nDo you want to continue?" \
		           /SD IDYES \
		           IDYES lbl_allowremoveshellex
		Abort
		lbl_allowremoveshellex:
	${EndIf}
FunctionEnd

Function un.onInit
!ifdef KRITA_INSTALLER_64
	${If} ${RunningX64}
		SetRegView 64
	${Else}
		Abort
	${Endif}
!else
	${If} ${RunningX64}
		SetRegView 64
	${Else}
		${DeselectSection} ${SEC_un_shellex_x64}
	${Endif}
!endif
FunctionEnd

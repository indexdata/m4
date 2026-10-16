; Common NSIS macro for YAZ, Zebra, etc
; Copyright (C) Index Data
; See the file LICENSE for details.

!include "LogicLib.nsh"
!include "WordFunc.nsh"

!define VSVER "$%VisualStudioVersion%"

!define VS_REDIST_EXE "vc_redist.${VSARCH}.exe"

; VS 2017 and later define VCToolsRedistDir.
!if "${VSVER}" == "14.0"
!define VS_REDIST_FULL "$%VSINSTALLDIR%\VC\redist\1033\${VS_REDIST_EXE}"
!else
!define VS_REDIST_FULL "$%VCToolsRedistDir%${VS_REDIST_EXE}"
!endif

; Use the bundled package's version rather than a release-specific MSI product ID.
!getdllversion "${VS_REDIST_FULL}" VS_REDIST_VERSION_
!define VS_REDIST_VERSION "${VS_REDIST_VERSION_1}.${VS_REDIST_VERSION_2}.${VS_REDIST_VERSION_3}.${VS_REDIST_VERSION_4}"

; VS 2015 and later share the v14 runtime registry key.
!if ${VS_REDIST_VERSION_1} != 14
!error "Unsupported Visual C++ runtime major version: ${VS_REDIST_VERSION_1}"
!endif
!define VS_REDIST_KEY "SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\${VSARCH}"

!if "${VSARCH}" == "x64"
; 64-bit
InstallDir "$PROGRAMFILES64\$(^Name)"
!else if "${VSARCH}" == "x86"
; 32-bit
InstallDir "$PROGRAMFILES\$(^Name)"
!else
!error "Unsupported Visual C++ runtime architecture: ${VSARCH}"
!endif

; Call inside an install section after SetOutPath selects a writable directory:
;   !insertmacro InstallVSRedist
; Preserves $0-$3, the registry view, and the output directory.
!macro InstallVSRedist
!if "${VS_REDIST_FULL}" != ""
	Push $0
	Push $1
	Push $2
	Push $3
	; The runtime registration is available in the 32-bit registry view,
	; with separate subkeys for x86 and x64 packages.
	SetRegView 32
	ReadRegDWORD $0 HKLM "${VS_REDIST_KEY}" "Installed"
	ReadRegStr $1 HKLM "${VS_REDIST_KEY}" "Version"
	SetRegView lastused
	StrCpy $2 2 ; Install if the runtime is absent or its version is unknown.
	${If} $0 == 1
	${AndIf} $1 != ""
	  ; Registry versions can have a leading "v" (e.g. v14.44.35211.00).
	  StrCpy $3 $1 1
	  ${If} $3 == "v"
	    StrCpy $1 $1 "" 1
	  ${EndIf}
	  ${VersionCompare} "$1" "${VS_REDIST_VERSION}" $2
	${EndIf}
	${If} $2 == 2 ; Installed version is older than the bundled package.
	  File "${VS_REDIST_FULL}"
	  ExecWait '"$OUTDIR\${VS_REDIST_EXE}" /install /passive /norestart'
	  Delete "$OUTDIR\${VS_REDIST_EXE}"
	${EndIf}
	Pop $3
	Pop $2
	Pop $1
	Pop $0
!endif
!macroend


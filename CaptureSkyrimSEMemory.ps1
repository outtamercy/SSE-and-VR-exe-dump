param(
    [int]$DelaySeconds = 60
)

$ErrorActionPreference = 'Stop'
$dumpDirectory = Join-Path $PSScriptRoot 'SE-Dumps'
New-Item -ItemType Directory -Force -Path $dumpDirectory | Out-Null

Add-Type @'
using System;
using System.Runtime.InteropServices;

namespace SkyrimSEDump {
    public static class Native {
        [DllImport("Dbghelp.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool MiniDumpWriteDump(
            IntPtr process,
            uint processId,
            IntPtr file,
            uint dumpType,
            IntPtr exceptionParam,
            IntPtr userStreamParam,
            IntPtr callbackParam);
    }
}
'@

Write-Host "Waiting for SkyrimSE.exe. Get to the main menu and let this thing do its job."

do {
    $process = Get-Process -Name 'SkyrimSE' -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $process) {
        Start-Sleep -Seconds 2
    }
} until ($process)

Write-Host "SkyrimSE found. Giving Steam $DelaySeconds seconds to peel the wrapper off..."
Start-Sleep -Seconds $DelaySeconds

$process = Get-Process -Id $process.Id -ErrorAction SilentlyContinue
if (-not $process) {
    throw "SkyrimSE quit before the dump happened. Rude, but at least it saved us a giant file."
}

$stamp = Get-Date -Format 'yyyy-MM-dd_HH-mm-ss'
$dumpPath = Join-Path $dumpDirectory "SkyrimSE-$stamp.dmp"
$stream = [System.IO.File]::Open($dumpPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)

try {
    # MiniDumpWithFullMemory. This is big on purpose; the unpacked code is what we need.
    $fullMemory = [uint32]0x00000002
    $ok = [SkyrimSEDump.Native]::MiniDumpWriteDump(
        $process.Handle,
        [uint32]$process.Id,
        $stream.SafeFileHandle.DangerousGetHandle(),
        $fullMemory,
        [IntPtr]::Zero,
        [IntPtr]::Zero,
        [IntPtr]::Zero)

    if (-not $ok) {
        $code = [Runtime.InteropServices.Marshal]::GetLastWin32Error()
        throw "Windows refused the dump (error $code). Right-click the bat and run it as admin next time."
    }
}
finally {
    $stream.Dispose()
}

Write-Host "Dump done: $dumpPath"
Write-Host "Keep it. This is the useful giant file, not random Steam-encrypted nonsense."

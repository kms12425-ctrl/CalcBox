#Requires -Version 5.1
<#
.SYNOPSIS
  校验 HAP 是否已正确签名。

.DESCRIPTION
  调用 SDK 自带的 hap-sign-tool 检查产物签名，并输出证书链与 Profile 路径。
  签名通过退出码 0，未通过 1，缺少依赖或产物 2，便于接到 CI 里。

.PARAMETER Hap
  HAP 路径。默认在 entry/build/default/outputs 下找最新的 .hap。

.EXAMPLE
  .\tools\verify-hap.ps1
  .\tools\verify-hap.ps1 -Hap entry\build\default\outputs\default\entry-default-signed.hap
#>
param(
    [string]$Hap = ''
)

$sdkLib = 'C:\Program Files\Huawei\DevEco Studio\sdk\default\openharmony\toolchains\lib'
$javaExe = 'C:\Program Files\Huawei\DevEco Studio\jbr\bin\java.exe'
$signTool = Join-Path $sdkLib 'hap-sign-tool.jar'

foreach ($path in @($javaExe, $signTool)) {
    if (-not (Test-Path $path)) {
        Write-Host "找不到依赖: $path" -ForegroundColor Red
        Write-Host '请修改本脚本顶部的路径，使其指向本机 DevEco Studio 的安装位置。'
        exit 2
    }
}

if ($Hap -eq '') {
    $outputs = Join-Path $PSScriptRoot '..\entry\build\default\outputs'
    $candidate = Get-ChildItem $outputs -Recurse -Filter '*.hap' -ErrorAction SilentlyContinue |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($null -eq $candidate) {
        Write-Host '没有找到 HAP，请先构建：hvigorw assembleHap --mode module -p product=default' -ForegroundColor Yellow
        exit 2
    }
    $Hap = $candidate.FullName
}

if (-not (Test-Path $Hap)) {
    Write-Host "找不到 HAP: $Hap" -ForegroundColor Red
    exit 2
}

$work = Join-Path ([System.IO.Path]::GetTempPath()) ('verify-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $work -Force | Out-Null
$cert = Join-Path $work 'chain.cer'
$profile = Join-Path $work 'profile.p7b'

Write-Host "校验产物: $Hap"

# java 会把正常日志写到 stderr，这里不能让它触发终止
$ErrorActionPreference = 'Continue'
$output = (& $javaExe -jar $signTool verify-app -inFile $Hap `
    -outCertChain $cert -outProfile $profile 2>&1) | Out-String
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host '签名校验通过' -ForegroundColor Green
    Write-Host "  证书链: $cert"
    Write-Host "  Profile: $profile"
    exit 0
}

Write-Host '签名校验失败' -ForegroundColor Red
($output -split "`n" | Where-Object { $_ -match 'ERROR -' -and $_ -notmatch 'CategoryInfo|FullyQualifiedErrorId' } | Select-Object -Last 3) |
    ForEach-Object { Write-Host ("  " + $_.Trim()) }
Write-Host ''
Write-Host '常见原因：'
Write-Host '  1. 产物是 unsigned —— 尚未在 DevEco 里配置 signingConfigs'
Write-Host '  2. 证书与 Profile 不匹配，或 Profile 里的 bundle-name 与实际包名不一致'
Write-Host '  3. Profile 已过期，或设备 UDID 不在调试 Profile 的 device-ids 里'
exit 1

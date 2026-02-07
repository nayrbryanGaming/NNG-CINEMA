<#
PowerShell helper: update_github_description.ps1

Usage:
- Option A (recommended): install GitHub CLI (gh) and run the script; it will use gh to update repo description.
- Option B: if gh is not available, the script will ask for a Personal Access Token (PAT) and call GitHub REST API.

Run from project root (PowerShell):
  cd E:\00ANDROIDSTUDIOPROJECT\2NNG_CINEMA_by_nayrbryanGaming
  .\scripts\update_github_description.ps1 -Token <your_token>

This script DOES NOT store your PAT. It only uses it for the API call during execution.
#>

param(
    [Parameter(Mandatory=$false)]
    [string]$Token
)

$owner = 'nayrbryanGaming'
$repo  = 'NNG-CINEMA'
$description = 'Flutter Educational Demo Project — Cinema System Simulation. THIS IS A SIMULATION/EDUCATIONAL PROJECT ONLY; does NOT integrate with real cinemas or payment systems.'
$homepage = "https://github.com/$owner/$repo"

Write-Host "Repository: $owner/$repo`nTarget description:`n$description`n"

# Check for gh
$ghPath = (Get-Command gh -ErrorAction SilentlyContinue)
if ($ghPath) {
    Write-Host "gh detected at $($ghPath.Source). Will use GitHub CLI to update repository metadata..."
    try {
        gh repo edit "$owner/$repo" --description "$description" --homepage "$homepage"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Updated repo description using gh"
            exit 0
        } else {
            Write-Host "gh returned non-zero exit code: $LASTEXITCODE"
        }
    } catch {
        Write-Host "gh invocation failed: $($_.Exception.Message)"
    }
}

Write-Host "gh not found or failed. Using GitHub REST API option. You may provide a Personal Access Token (PAT) via -Token parameter or set environment variable GITHUB_TOKEN."

# Accept token from parameter or environment
if (-not $Token) {
    $envToken = [Environment]::GetEnvironmentVariable('GITHUB_TOKEN')
    if ($envToken) { $Token = $envToken }
}

if (-not $Token) {
    Write-Host "No token provided via -Token or GITHUB_TOKEN. Prompting for token interactively (input hidden)."
    $secureToken = Read-Host -AsSecureString "Enter GitHub Personal Access Token (input hidden) or press ENTER to abort"
    if (-not $secureToken) {
        Write-Host "No token provided. Aborting."
        exit 1
    }
    $Token = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secureToken))
}

$body = @{ description = $description; homepage = $homepage } | ConvertTo-Json

try {
    $uri = "https://api.github.com/repos/$owner/$repo"
    $headers = @{ Authorization = "token $Token"; "User-Agent" = "PowerShell" }
    Write-Host "Calling GitHub API: PATCH $uri"
    $resp = Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -Body $body -ContentType 'application/json'
    Write-Host "Repository updated. New description:`n$($resp.description)"
    exit 0
} catch {
    Write-Host "API call failed:`n$($_.Exception.Message)"
    exit 2
}

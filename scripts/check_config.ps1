# PowerShell helper: validate google-services.json and produce keystore SHA-1
# Run from repo root: .\scripts\check_config.ps1

Write-Host "Running google-services.json validator..."
if (Test-Path .\android\app\google-services.json) {
  try {
    $raw = Get-Content .\android\app\google-services.json -Raw -ErrorAction Stop
    $json = $raw | ConvertFrom-Json
    Write-Host "Found google-services.json"
    Write-Host "project_id:`t" $json.project_info.project_id
    Write-Host "project_number:`t" $json.project_info.project_number

    # summarize clients
    if ($json.client -and $json.client.Count -gt 0) {
      for ($i = 0; $i -lt $json.client.Count; $i++) {
        $c = $json.client[$i]
        Write-Host "--- client index: $i ---"
        if ($c.client_info) {
          if ($c.client_info.android_client_info -and $c.client_info.android_client_info.package_name) {
            Write-Host "package_name:`t" $c.client_info.android_client_info.package_name
          }
          if ($c.client_info.mobilesdk_app_id) { Write-Host "mobilesdk_app_id:`t" $c.client_info.mobilesdk_app_id }
        }

        if ($c.oauth_client -and $c.oauth_client.Count -gt 0) {
          Write-Host "oauth_client entries:`t" $c.oauth_client.Count
          foreach ($oc in $c.oauth_client) {
            if ($oc.android_info) {
              Write-Host "  client_id:`t" $oc.client_id
              Write-Host "  client_type:`t" $oc.client_type
              Write-Host "  android package:`t" $oc.android_info.package_name
              Write-Host "  certificate_hash:`t" $oc.android_info.certificate_hash
            } else {
              Write-Host "  client_id:`t" $oc.client_id " (no android_info)"
            }
          }
        } else {
          Write-Host "oauth_client entries:`t 0 (missing)"
        }

        if ($c.api_key -and $c.api_key.Count -gt 0) {
          Write-Host "api_key(s):"
          foreach ($k in $c.api_key) { Write-Host "  -" $k.current_key }
        }
      }
    } else {
      Write-Host "No clients found in google-services.json"
    }

    # Additional validation: is there any oauth_client android entry with certificate_hash?
    $androidOauths = @()
    foreach ($c in $json.client) {
      if ($c.oauth_client) {
        foreach ($oc in $c.oauth_client) {
          if ($oc.android_info -and $oc.android_info.certificate_hash) {
            $androidOauths += [pscustomobject]@{
              client_id = $oc.client_id
              package = $oc.android_info.package_name
              sha1 = $oc.android_info.certificate_hash
            }
          }
        }
      }
    }
    if ($androidOauths.Count -eq 0) {
      Write-Host "\nWARNING: No Android oauth_client entries with certificate_hash found in google-services.json." -ForegroundColor Yellow
      Write-Host "This will cause Google Sign-In errors (e.g. ApiException: 10 / CONFIGURATION_NOT_FOUND)."
    } else {
      Write-Host "\nFound Android oauth_client entries with SHA-1(s):"
      $androidOauths | ForEach-Object { Write-Host "  package:`t$($_.package)  sha1:`t$($_.sha1)" }
    }

  } catch {
    Write-Host "Failed to parse google-services.json: $_"
  }
} else {
  Write-Host "ERROR: android/app/google-services.json not found" -ForegroundColor Red
}

Write-Host "\nRunning Gradle signingReport (requires JDK + Gradle wrapper)..."
Push-Location android
if (Test-Path .\gradlew) {
  try {
    $out = & .\gradlew signingReport 2>&1
    # print raw output first
    Write-Host "--- gradlew signingReport output (truncated) ---"
    # show only relevant lines and the tail to avoid huge output
    $outLines = $out -split "`n"
    $outLines | Select-Object -First 200 | ForEach-Object { Write-Host $_ }

    # extract SHA1 lines
    $sha1s = @()
    foreach ($l in $outLines) {
      if ($l -match "SHA1:\s*([0-9A-F:]{2,})") {
        $sha = $matches[1].Trim()
        if (-not ($sha1s -contains $sha)) { $sha1s += $sha }
      }
    }
    if ($sha1s.Count -gt 0) {
      Write-Host "\nExtracted SHA-1 from signingReport:"
      $sha1s | ForEach-Object { Write-Host "  - $_" }
    } else {
      Write-Host "\nNo SHA-1 lines found in signingReport output." -ForegroundColor Yellow
    }

    # try to match extracted SHA1 vs google-services.json oauth entries
    if (Test-Path ..\android\app\google-services.json) {
      $raw = Get-Content ..\android\app\google-services.json -Raw | ConvertFrom-Json
      $oauthSha = @()
      foreach ($c in $raw.client) {
        if ($c.oauth_client) {
          foreach ($oc in $c.oauth_client) {
            if ($oc.android_info -and $oc.android_info.certificate_hash) { $oauthSha += $oc.android_info.certificate_hash }
          }
        }
      }
      if ($oauthSha.Count -eq 0) {
        Write-Host "\nNote: google-services.json has no Android oauth_client SHA-1 entries to compare against." -ForegroundColor Yellow
      } else {
        Write-Host "\nComparing signingReport SHA-1 to google-services.json entries..."
        $foundAny = $false
        foreach ($s in $sha1s) {
          if ($oauthSha -contains $s) { Write-Host "  OK: SHA-1 $s exists in google-services.json"; $foundAny = $true } else { Write-Host "  MISSING in google-services.json: $s" }
        }
        if (-not $foundAny) {
          Write-Host "\nACTION REQUIRED:" -ForegroundColor Red
          Write-Host "  1) Go to Firebase Console -> Project settings -> Add Android app (package name: com.nng_cinema) or add fingerprint SHA-1 ($($sha1s -join ', '))."
          Write-Host "  2) Enable Google Sign-In under Authentication -> Sign-in method."
          Write-Host "  3) Download updated google-services.json and replace android/app/google-services.json in this repo."
          Write-Host "  4) Rebuild app. ApiException:10 happens when OAuth client SHA-1 not configured or package/SHA mismatch."
        }
      }
    }

  } catch {
    Write-Host "Failed to run gradlew signingReport: $_" -ForegroundColor Red
  }
} else {
  Write-Host "gradlew wrapper not found in android/ — open Android Studio and run Gradle -> signingReport" -ForegroundColor Yellow
}
Pop-Location

Write-Host "\nCheck complete. If you saw project_id and package_name above, ensure SHA-1 from signingReport is added to Firebase Console and then redownload google-services.json."

# Quick helper: print short checklist for the user to fix Google Sign-In errors
Write-Host "\nQuick checklist to fix Google Sign-In (ApiException:10 / CONFIGURATION_NOT_FOUND):" -ForegroundColor Cyan
Write-Host " - Confirm android package name in google-services.json matches your app (com.nng_cinema)."
Write-Host " - From the signingReport, copy the SHA-1 (debug/release) and add them in Firebase Console (Project settings -> General -> Your apps -> Add fingerprint)."
Write-Host " - In Firebase Console -> Authentication -> Sign-in method: enable 'Google'."
Write-Host " - Download new google-services.json and overwrite android/app/google-services.json."
Write-Host " - Clean and rebuild the app (flutter clean && flutter pub get && flutter run)."
Write-Host " - If using Google Sign-In on Android, ensure your OAuth client exists in the Firebase project's OAuth clients (google-services.json oauth_client entries)."

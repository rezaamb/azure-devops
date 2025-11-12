trigger: none

pool: Test

steps:
- pwsh: |
    Write-Host "Pipeline YAML repo ref  = $env:BUILD_SOURCEBRANCH"
    Write-Host "Pipeline YAML branch    = $env:BUILD_SOURCEBRANCHNAME"
  displayName: Echo branch (pwsh)

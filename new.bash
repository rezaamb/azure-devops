trigger: none

pool:
  name: Test

variables:
  buildConfiguration: 'Release'

steps:
- checkout: self

# 1) فقط برای اطمینان از نسخه‌ی dotnet
- pwsh: |
    & "C:\Program Files\dotnet\dotnet.exe" --info
  displayName: 'Dotnet info'

# 2) Restore
- pwsh: |
    & "C:\Program Files\dotnet\dotnet.exe" restore `
      "Taday.Corelibrary/Taday.Corelibrary.csproj"
  displayName: 'Restore'

# 3) Build + Pack (خود پروژه GeneratePackageOnBuild=true دارد)
- pwsh: |
    & "C:\Program Files\dotnet\dotnet.exe" build `
      "Taday.Corelibrary/Taday.Corelibrary.csproj" `
      --configuration $(buildConfiguration) `
      /p:GeneratePackageOnBuild=true `
      /p:PackageOutputPath=$(Build.ArtifactStagingDirectory)
  displayName: 'Build & Pack'

# 4) Push به فید با Windows Auth (بدون PAT)
- pwsh: |
    Write-Host "Packages in $(Build.ArtifactStagingDirectory):"
    Get-ChildItem "$(Build.ArtifactStagingDirectory)" -Filter *.nupkg | ForEach-Object {
      Write-Host " - $($_.FullName)"
    }

    & "C:\Program Files\dotnet\dotnet.exe" nuget push `
      "$(Build.ArtifactStagingDirectory)\*.nupkg" `
      --source "Taday.CoreLibraryPackages" `
      --skip-duplicate
  displayName: 'Push package to Azure Artifacts via Windows Auth'

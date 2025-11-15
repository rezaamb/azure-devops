trigger: none

pool:
  name: Test

variables:
  buildConfiguration: 'Release'

steps:
# 1) گرفتن سورس
- checkout: self

# 2) اطلاعات دات‌نت (فقط برای دیباگ و اطمینان)
- pwsh: |
    & "C:\Program Files\dotnet\dotnet.exe" --info
  displayName: 'Dotnet info'

# 3) Restore پکیج‌ها
- pwsh: |
    & "C:\Program Files\dotnet\dotnet.exe" restore `
      "Taday.Corelibrary/Taday.Corelibrary.csproj"
  displayName: 'Restore'

# 4) Build + Pack (با GeneratePackageOnBuild و خروجی در ArtifactStagingDirectory)
- pwsh: |
    & "C:\Program Files\dotnet\dotnet.exe" build `
      "Taday.Corelibrary/Taday.Corelibrary.csproj" `
      --configuration $(buildConfiguration) `
      /p:GeneratePackageOnBuild=true `
      /p:PackageOutputPath=$(Build.ArtifactStagingDirectory)
  displayName: 'Build & Pack'

# 5) Push پکیج‌ها به Azure Artifacts با Windows Auth
- pwsh: |
    Write-Host "Packages in $(Build.ArtifactStagingDirectory):"
    Get-ChildItem "$(Build.ArtifactStagingDirectory)" -Filter *.nupkg | ForEach-Object {
      Write-Host " - $($_.FullName)"
    }

    & "C:\Program Files\dotnet\dotnet.exe" nuget push `
      "$(Build.ArtifactStagingDirectory)\*.nupkg" `
      --source "Taday.CoreLibraryPackages" `
      --api-key "AzureDevOps" `
      --skip-duplicate
  displayName: 'Push package to Azure Artifacts via Windows Auth'

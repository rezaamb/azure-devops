trigger: none

pool:
  name: Test

variables:
  buildConfiguration: 'Release'

steps:
# 1) گرفتن سورس
- checkout: self

# 2) Dotnet info  (فقط دیباگ)
- task: CmdLine@2
  displayName: 'Dotnet info'
  env:
    PATH: 'C:\Program Files\dotnet;$(PATH)'
  inputs:
    script: 'dotnet --info'

# 3) Restore پکیج‌ها
- task: DotNetCoreCLI@2
  displayName: 'Restore'
  env:
    PATH: 'C:\Program Files\dotnet;$(PATH)'
  inputs:
    command: 'restore'
    projects: 'Taday.Corelibrary/Taday.Corelibrary.csproj'

# 4) Build + Pack (GeneratePackageOnBuild + خروجی در ArtifactStagingDirectory)
- task: DotNetCoreCLI@2
  displayName: 'Build & Pack'
  env:
    PATH: 'C:\Program Files\dotnet;$(PATH)'
  inputs:
    command: 'build'
    projects: 'Taday.Corelibrary/Taday.Corelibrary.csproj'
    arguments: >
      --configuration $(buildConfiguration)
      /p:GeneratePackageOnBuild=true
      /p:PackageOutputPath=$(Build.ArtifactStagingDirectory)

# 5) Push پکیج‌ها به Azure Artifacts با Windows Auth
- task: DotNetCoreCLI@2
  displayName: 'Push package to Azure Artifacts via Windows Auth'
  env:
    PATH: 'C:\Program Files\dotnet;$(PATH)'
  inputs:
    command: 'custom'
    custom: 'nuget'
    arguments: >
      push "$(Build.ArtifactStagingDirectory)\*.nupkg"
      --source "Taday.CoreLibraryPackages"
      --api-key "AzureDevOps"
      --skip-duplicate

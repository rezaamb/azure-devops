trigger:
  branches:
    include:
      - main
      - develop

pool:
  name: 'CoreLibraryPublish'

variables:
  buildConfiguration: 'Release'


steps:
# بررسی نسخه‌ی فعلی .NET در Agent برای شفافیت
#- script: dotnet --info
 # displayName: 'Show .NET SDK info (before install)'
#- checkout: self
 # persistCredentials: true 

# install SDK version 9.0
- task: UseDotNet@2
  displayName: 'Install .NET 9 SDK'
  env:
    HTTP_PROXY: "http://proxy.tad.local:3128"
    HTTPS_PROXY: "http://proxy.tad.local:3128"
  inputs:
    packageType: 'sdk'
    version: '9.0.x'
    includePreviewVersions: true

- script: dotnet --info
  displayName: 'Show .NET SDK info (after install)'

# 3) Restore 
- task: DotNetCoreCLI@2
  displayName: 'Restore'
  inputs:
    command: 'restore'
    projects: 'Taday.Corelibrary/Taday.Corelibrary.csproj'

# 4) Build + Pack 
- task: DotNetCoreCLI@2
  displayName: 'Build & Pack'
  inputs:
    command: 'build'
    projects: 'Taday.Corelibrary/Taday.Corelibrary.csproj'
    arguments: >
      --configuration $(buildConfiguration)
      /p:GeneratePackageOnBuild=true
      /p:PackageOutputPath=$(Build.ArtifactStagingDirectory)

# push packages to Artifacts
- task: DotNetCoreCLI@2
  displayName: 'Push package to Azure Artifacts via Windows Auth'
  inputs:
    command: 'custom'
    custom: 'nuget'
    arguments: >
      push "$(Build.ArtifactStagingDirectory)\*.nupkg"
      --source "Taday.CoreLibraryPackages"
      --api-key "AzureDevOps"
      --skip-duplicate

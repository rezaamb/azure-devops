trigger:
  branches:
    include:
      - main
      - develop

pool:
  name: 'CoreLibraryPublish'
  
variables:
  buildConfiguration: 'Release'
  packageVersion: '8.0.$(Build.BuildId)'

steps:
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

- task: DotNetCoreCLI@2
  displayName: 'Restore'
  inputs:
    command: 'restore'
    projects: 'Taday.Corelibrary/Taday.Corelibrary.csproj'

- task: DotNetCoreCLI@2
  displayName: 'Build & Pack'
  inputs:
    command: 'build'
    projects: 'Taday.Corelibrary/Taday.Corelibrary.csproj'
    arguments: >
      --configuration $(buildConfiguration)
      /p:GeneratePackageOnBuild=true
      /p:PackageOutputPath=$(Build.ArtifactStagingDirectory)
      /p:Version=$(packageVersion)
      /p:PackageVersion=$(packageVersion)

- script: |
    echo "=== LIST NUPKGs IN $(Build.ArtifactStagingDirectory) ==="
    dir "$(Build.ArtifactStagingDirectory)"
  displayName: 'List nupkg files'

- task: DotNetCoreCLI@2
  displayName: 'Push package to Azure Artifacts (Windows Auth)'
  inputs:
    command: 'custom'
    custom: 'nuget'
    arguments: >
      push "$(Build.ArtifactStagingDirectory)\*.nupkg"
      --source "https://azure.taday.ir/DefaultCollection/_packaging/Taday.CoreLibraryPackages/nuget/v2/"
      --api-key "AzureDevOps"
      --skip-duplicate

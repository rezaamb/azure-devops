trigger:
  branches:
    include:
      - main
      - develop

pool:
  name: Test

variables:
  buildConfiguration: 'Release'

steps:
- checkout: self

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

- task: PublishPipelineArtifact@1
  displayName: 'Publish nupkg as pipeline artifact'
  inputs:
    targetPath: '$(Build.ArtifactStagingDirectory)'
    artifact: 'nupkg'
    publishLocation: 'pipeline'

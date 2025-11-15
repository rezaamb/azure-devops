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

# نصب SDK نسخه 9.0 (در صورت نیاز پروژه)
- task: UseDotNet@2
  displayName: 'Install .NET 9 SDK'
  inputs:
    packageType: 'sdk'
    version: '9.0.x'
    includePreviewVersions: true   # اگر پروژه از Preview استفاده نمی‌کند می‌توان حذف کرد

# نمایش نسخه بعد از نصب برای اطمینان
- script: dotnet --info
  displayName: 'Show .NET SDK info (after install)'

# بازگردانی پکیج‌ها
- task: DotNetCoreCLI@2
  displayName: 'Restore packages'
  inputs:
    command: 'restore'
    projects: '**/*.csproj'

# ساخت پروژه
- task: DotNetCoreCLI@2
  displayName: 'Build project'
  inputs:
    command: 'build'
    projects: '**/*.csproj'
    arguments: '--configuration $(buildConfiguration)'

# ساخت بسته‌های NuGet
- task: DotNetCoreCLI@2
  displayName: 'Build and Pack project'
  inputs:
    command: 'build'
    projects: '**/*.csproj'
    arguments: '--configuration $(BuildConfiguration) /p:GeneratePackageOnBuild=true /p:PackageOutputPath=$(Build.ArtifactStagingDirectory)'

- task: NuGetAuthenticate@1
  displayName: 'Authenticate to Azure Artifacts'
  
- task: DotNetCoreCLI@2
  displayName: 'Push to Azure Artifacts'
  inputs:
    command: 'push'
    packagesToPush: '$(Build.ArtifactStagingDirectory)/*.nupkg'
    nuGetFeedType: 'internal'
    #publishVstsFeed: '5a53e661-277d-4a8f-a6f8-a4342f6b9c51'
    publishVstsFeed: 'Taday.CoreLibraryPackages'

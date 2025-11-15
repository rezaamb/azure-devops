trigger:
  branches:
    include:
      - stage
      - prod

pool:
  name: 'Test'

stages:
- stage: Build
  jobs:
  - job: Build
    steps:
    - script: |
        echo "=== BUILD STAGE ==="
        echo "Source branch      : $(Build.SourceBranch)"
        echo "Source branch name : $(Build.SourceBranchName)"
      displayName: 'Dummy build'

- stage: DeployStage
  dependsOn: Build
  condition: and(
               succeeded(),
               eq(variables['Build.SourceBranchName'], 'stage')
             )
  jobs:
  - job: DeployToStage
    steps:
    - script: |
        echo "=== DEPLOY TO STAGING ==="
        echo "Branch        : $(Build.SourceBranch)"
        echo "BranchName    : $(Build.SourceBranchName)"
      displayName: 'Dummy deploy staging'

- stage: DeployProd
  dependsOn: Build
  condition: and(
               succeeded(),
               eq(variables['Build.SourceBranchName'], 'prod')
             )
  jobs:
  - job: DeployToProd
    steps:
    - script: |
        echo "=== DEPLOY TO PRODUCTION ==="
        echo "Branch        : $(Build.SourceBranch)"
        echo "BranchName    : $(Build.SourceBranchName)"
      displayName: 'Dummy deploy production'

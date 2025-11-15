trigger:
  branches:
    include:
      - staging
      - master

pool:
  name: 'Test'

parameters:
- name: tag
  displayName: Deployment tag
  type: string
  default: stage
  values:
  - stage
  - prod

stages:
# ───────────── Build Stage ─────────────
- stage: Build
  jobs:
  - job: Build
    steps:
    - script: |
        echo "=== BUILD STAGE ==="
        echo "Source branch : $(Build.SourceBranch)"
        echo "Tag (param)   : ${{ parameters.tag }}"
      displayName: 'Dummy build'

# ───────────── Deploy to STAGING ─────────────
- stage: DeployStaging
  condition: and(
               succeeded(),
               eq(variables['Build.SourceBranch'], 'refs/heads/staging'),
               eq('${{ parameters.tag }}', 'stage')
             )
  jobs:
  - job: DeployToStaging
    steps:
    - script: |
        echo "=== DEPLOY TO STAGING ==="
        echo "Branch        : $(Build.SourceBranch)"
        echo "Tag (param)   : ${{ parameters.tag }}"
      displayName: 'Dummy deploy staging'

# ───────────── Deploy to PRODUCTION ─────────────
- stage: DeployProduction
  condition: and(
               succeeded(),
               eq(variables['Build.SourceBranch'], 'refs/heads/master'),
               eq('${{ parameters.tag }}', 'prod')
             )
  jobs:
  - job: DeployToProduction
    steps:
    - script: |
        echo "=== DEPLOY TO PRODUCTION ==="
        echo "Branch        : $(Build.SourceBranch)"
        echo "Tag (param)   : ${{ parameters.tag }}"
      displayName: 'Dummy deploy production'

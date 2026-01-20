# Create GitHub Repositories

## Overview
This Branch focusing on establishing the initial GitHub repository structure and enforcing basic governance standards.

## Objectives
- Create the GitHub repository
- Add a README
- Enable branch protection rules


### Contribution Guidelines
1. Create a new branch from `dev`
2. Make your changes with clear commit messages
3. Open a Pull Request
4. Ensure all checks pass and reviews are approved before merging


---

#  Define Branching Strategy

## Overview
Defines the branching strategy for the repository, ensuring a consistent and controlled Git workflow for development, releases, and maintenance.

## Objectives
- Define and document the Git branching model
- Apply and enforce branch protection rules


## Branching Strategy 

### Main Branches
- **main**
  - Represents production-ready code
  - Always stable and deployable
  - Protected against direct commits

- **dev**
  - Integration branch for ongoing development
  - Contains the latest completed features
  - Merges into `main` for releases

### Supporting Branches
- **feature/\***
  - Used for developing new features
  - Branched from: `dev`
  - Merged back into: `dev`
  - Naming example: `dev/initializationAndGovernance`


## Branch Protection Rules
### Protected Branches
The following branches are protected:
- `main`
- `dev`

### Protection Settings
- Pull Requests required before merging
- Minimum of one approving review
- Status checks must pass before merging 
- Branch must be up to date before merge

## Pull Request Guidelines
- Keep PRs focused and small
- Ensure code passes all tests and checks
- Obtain required approvals before merging



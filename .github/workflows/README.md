## GitHub Actions Workflows
### Triggered on every push

- build.yml: This is the main workflow that renders the whole quarto project using a quarto docker container and pushes it to gh-pages branch.
- spellcheck.yml: This workflow checks the spelling in all project files.
- linkcheck.yml: This workflow checks for broken links in all .md and .qmd files.

### Triggered manually

- docker.yml: This workflow builds a docker container with all tools needs for the labs and pushes it to NBISweden GHCR repository.

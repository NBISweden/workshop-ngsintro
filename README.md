# workshop-ngsintro  

[![gh-actions-build-status](https://github.com/nbisweden/workshop-ngsintro/workflows/build/badge.svg)](https://github.com/nbisweden/workshop-ngsintro/actions?workflow=build)  [![linkcheck_badge](https://github.com/nbisweden/workshop-ngsintro/workflows/linkcheck/badge.svg)](https://github.com/nbisweden/workshop-ngsintro/actions?workflow=linkcheck)  [![spellcheck_badge](https://github.com/nbisweden/workshop-ngsintro/workflows/spellcheck/badge.svg)](https://github.com/nbisweden/workshop-ngsintro/actions?workflow=spellcheck)  

This repo contains the course material for NBIS workshop **Introduction to Bioinformatics using NGS data**. The rendered view of this repo is available [here](https://nbisweden.github.io/workshop-ngsintro/).

## Contributing

To add or update contents of this repo (for collaborators), first clone the repo.

```
git clone --depth 1 --single-branch --branch master https://github.com/nbisweden/workshop-ngsintro.git
```

Make changes/updates as needed. Add the changed files. Commit it. Then push the repo back.

```
git add .
git commit -m "I did this and that"
git push origin
```

If you are not added as a collaborator, first fork this repo to your account, then clone it locally, make changes, commit, push to your repo, then submit a pull request to this repo.

:exclamation: When updating repo for a new course, change `output-dir: XXXX` in `_quarto.yml` 
as the first thing, so that old rendered files are not overwritten.

:exclamation: Do not push any rendered .html files or intermediates.

## Docker
### Local build/preview using Docker

You can preview changes and build the whole website locally without a local installation of R or dependency packages by using the pre-built Docker image.

Clone the repo if not already done. Make sure you are standing in the repo directory.

To render the complete site,

```
docker run --rm -v ${PWD}:/work ghcr.io/quarto-dev/quarto:latest quarto render /work
```

To render a single file (for example `index.qmd`),

```
docker run --rm -v ${PWD}:/work ghcr.io/quarto-dev/quarto:latest quarto render /work/index.qmd
```

:exclamation: Output files are for local preview only. Do not push any rendered .html files or intermediates.

### Convert HTML slides to PDF

```
docker run --platform=linux/amd64 -v $PWD:/work astefanutti/decktape https://nbisweden.github.io/workshop-ngsintro/2511/topics/rnaseq/slide_rnaseq.html /work/slide_rnaseq.pdf
```

### Serving and automatic rendering

You can use `quarto preview` to serve the site, and handle automatic rebuilding of pages when any `.qmd` file is changed.

```bash
# serve the site
docker run --rm -it -v ${PWD}:/work -p 8800:8800  ghcr.io/quarto-dev/quarto:latest quarto preview /work --port 8800 --host 0.0.0.0
```

Go to [http://localhost:8800/](http://localhost:8800/) or [http://0.0.0.0:8800](http://0.0.0.0:8800) in your browser.

## Repo organisation

The source material is located on the *master* branch (default). The rendered material is located on the *gh-pages* branch. One only needs to update source materials in *master*. Changes pushed to the *master* branch is automatically rendered to the *gh-pages* branch using github actions.

:exclamation: Every push rebuilds the whole website using a pre-built docker image.

This repo is loosely based on the quarto template [specky](https://github.com/royfrancis/specky).

## Test scripts

This is regarding the directory **scripts**. This directory contains shell scripts for vc (variant-calling) and rnaseq parts of the workshop. These are intended to be run on HPC. Further instructions on using them are available within the scripts.

The contents of these scripts should use identical steps and tools as the student would use in the lab. The aim of these scripts is to execute them on HPC before the course. This should provide insight into broken links, broken tools, tool incompatibilities, core usage, ram usage and total space used.

*The scripts directory is not used in this repo, tutorial or the website. It's just here as a backup.*

---

**2026** • NBIS • SciLifeLab

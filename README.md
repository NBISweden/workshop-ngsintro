# workshop-ngsintro [![gh-actions-build-status](https://github.com/nbisweden/workshop-ngsintro/workflows/build/badge.svg)](https://github.com/nbisweden/workshop-ngsintro/actions?workflow=build)

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

### Local build/preview using Docker

You can preview changes and build the whole website locally without a local installation of R or dependency packages by using the pre-built Docker image.

:exclamation: **Note:** Large image size: 4.68GB.

Clone the repo if not already done. Make sure you are standing in the repo directory.

To build the complete site,

```
docker run --platform linux/amd64 --rm -u 1000:1000 -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-ngsintro:latest
```

To build a single file (for example `index.qmd`),

```
docker run --platform linux/amd64 --rm -u 1000:1000 -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-ngsintro:latest quarto render index.qmd
```

:exclamation: Output files are for local preview only. Do not push any rendered .html files or intermediates.

## Convert HTML slides to PDF

```
docker run --platform=linux/amd64 -v $PWD:/work astefanutti/decktape https://nbisweden.github.io/workshop-ngsintro/2403/topics/rnaseq/slide_rnaseq.html /work/slide_rnaseq.pdf
```

## Repo organisation

The source material is located on the *master* branch (default). The rendered material is located on the *gh-pages* branch. One only needs to update source materials in *master*. Changes pushed to the *master* branch is automatically rendered to the *gh-pages* branch using github actions.

:exclamation: Every push rebuilds the whole website using a pre-built docker image.

This repo is loosely based on the quarto template [specky](https://github.com/royfrancis/specky).

## Building docker container

```bash
# build container
docker build --platform linux/amd64 -t ghcr.io/nbisweden/workshop-ngsintro:2.3.0 -t ghcr.io/nbisweden/workshop-ngsintro:latest .

# push to ghcr
# docker login ghcr.io
docker push ghcr.io/nbisweden/workshop-ngsintro:2.3.0
docker push ghcr.io/nbisweden/workshop-ngsintro:latest

# run container in the root of the repo
docker run --rm --platform linux/amd64 -u $(id -u):$(id -g) -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-ngsintro:latest
docker run --rm --platform linux/amd64 -u $(id -u):$(id -g) -v ${PWD}:/qmd ghcr.io/nbisweden/workshop-ngsintro:latest quarto render index.qmd
```

## Serving and automatic rendering

You can use `quarto preview` to serve the site, and handle automatic rebuilding of pages when any `.qmd` file is changed.

```bash
# serve the site
docker run --rm -it --platform linux/amd64 -u $(id -u):$(id -g) -v ${PWD}:/qmd -p 8800:8800  ghcr.io/nbisweden/workshop-ngsintro:latest quarto preview --port 8800 --host 0.0.0.0
```

Go to [http://localhost:8800/](http://localhost:8800/) or [http://0.0.0.0:8800](http://0.0.0.0:8800) in your browser.

## Test scripts

This is regarding the directory **scripts**. This directory contains shell scripts for reseq (variant-calling) and rnaseq parts of the workshop. These are intended to be run on UPPMAX. Further instructions on using them are available within the scripts.

The contents of these scripts should use identical steps and tools as the student would use in the lab. The aim of these scripts is to execute them on UPPMAX before the course. This should provide insight into broken links, broken tools, tool incompatibilities, core usage, ram usage and total space used.

*The scripts directory is not used in this repo, tutorial or the website. It's just here as a backup.*

---

**2024** • NBIS • SciLifeLab

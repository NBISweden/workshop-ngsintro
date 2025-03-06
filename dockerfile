# DOCKER FILE FOR WORKSHOP-NGSINTRO
# 2025 Roy Francis

FROM ghcr.io/rocker-org/verse:4.4.3
LABEL Description="Docker image for NBIS workshop"
LABEL Maintainer="roy.francis@nbis.se"
LABEL org.opencontainers.image.source="https://github.com/NBISweden/workshop-ngsintro"
ARG QUARTO_VERSION="1.6.42"

RUN apt-get update -y \
  && apt-get clean \
  && apt-get install --no-install-recommends -y \
  libxml2-dev \
  libssl-dev \
  libcurl4-openssl-dev \
  libudunits2-dev \
  libgdal-dev \
  curl \
  #&& wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
  #&& apt-get install -y ./google-chrome-stable_current_amd64.deb \
  #&& rm -rf ./google-chrome-stable_current_amd64.deb \
  && curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb \
  && apt-get install -y ./quarto-linux-amd64.deb \
  && rm -rf ./quarto-linux-amd64.deb \
  && rm -rf /var/lib/apt/lists/* \
  && install2.r --error --skipinstalled remotes fontawesome here htmlTable leaflet readxl writexl \
  && rm -rf /tmp/downloaded_packages \
  && mkdir /qmd /.cache \
  && chmod 777 /qmd /.cache

USER rstudio

## Required when editing rnaseq lab
RUN Rscript -e 'install.packages(c("pheatmap","ggrepel"),repos = "http://cran.us.r-project.org"); BiocManager::install(c("DESeq2", "edgeR", "org.Mm.eg.db", "clusterProfiler"));'

WORKDIR /qmd
#ENV XDG_CACHE_HOME=/tmp/quarto_cache_home
#ENV XDG_DATA_HOME=/tmp/quarto_data_home
CMD ["quarto", "render"]

# local build
# docker build --platform linux/amd64 -t ghcr.io/nbisweden/workshop-ngsintro:2.5.0 -t ghcr.io/nbisweden/workshop-ngsintro:latest .
# multiplatform build and push to repository (doesn't work)
# docker buildx build --platform=linux/arm64,linux/amd64 -t ghcr.io/nbisweden/workshop-ngsintro:2.5.0 -t ghcr.io/nbisweden/workshop-ngsintro:latest --push -f Dockerfile .
# build singularity
# docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(pwd):/work kaczmarj/apptainer build ngsintro.sif docker://ghcr.io/nbisweden/workshop-ngsintro:latest

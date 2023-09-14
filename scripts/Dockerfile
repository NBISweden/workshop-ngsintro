# DOCKER FILE FOR WORKSHOP-NGSINTRO
# 2023 Roy Francis

FROM rocker/verse:4.2.3
LABEL Description="Docker image for NBIS workshop"
LABEL Maintainer="roy.francis@nbis.se"
LABEL org.opencontainers.image.source="https://github.com/NBISweden/workshop-ngsintro"
ARG QUARTO_VERSION="1.3.433"

RUN apt-get update -y \
    && apt-get install --no-install-recommends -y \
    libxml2-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libudunits2-dev \
    libopenblas-base \
    libgdal-dev \
    && wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb \
    && apt-get install -y ./google-chrome-stable_current_amd64.deb \
    && rm -rf ./google-chrome-stable_current_amd64.deb \
    && curl -o quarto-linux-amd64.deb -L https://github.com/quarto-dev/quarto-cli/releases/download/v${QUARTO_VERSION}/quarto-${QUARTO_VERSION}-linux-amd64.deb \
    && apt-get install -y ./quarto-linux-amd64.deb \
    && rm -rf ./quarto-linux-amd64.deb \
    && Rscript -e 'install.packages(c("remotes","here","htmlTable","leaflet"),repos = "http://cran.us.r-project.org");' \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /qmd

RUN Rscript -e 'BiocManager::install(c("DESeq2","edgeR","goseq","GO.db","org.Mm.eg.db","reactome.db"));'
WORKDIR /qmd
ENV XDG_CACHE_HOME=/tmp/quarto_cache_home
ENV XDG_DATA_HOME=/tmp/quarto_data_home
CMD quarto render



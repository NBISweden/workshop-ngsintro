# DOCKER FILE FOR WORKSHOP-NGSINTRO
# 2022 Roy Francis

FROM royfrancis/workshop-base:1.0.0
LABEL Description="Docker image for NBIS workshop-ngsintro"
LABEL Maintainer="roy.francis@nbis.se"

RUN Rscript -e 'BiocManager::install(c("DESeq2","edgeR","goseq","GO.db","org.Mm.eg.db","reactome.db"));'
WORKDIR /rmd
CMD Rscript -e "rmarkdown::render_site()"


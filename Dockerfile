# BUILD: docker build -t "toscm/fastret:0.99.6" .
# RUN: docker run -it --rm -p "3838:3838" "toscm/fastret:0.99.6"
# PUSH: docker push "toscm/fastret:0.99.6"
# DEVELOP: docker run -it --rm -p "3838:3838" -v "$(PWD):/home/shiny" "toscm/fastret:0.99.6" /bin/bash
FROM rocker/shiny-verse:4.1

# Install Requirements
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
RUN apt-get update && apt-get install --no-install-recommends -y \
        openjdk-8-jdk \
        gdebi-core \
        qpdf \
        devscripts \
        ghostscript \
        r-cran-devtools \
    && R CMD javareconf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install FastRet
RUN Rscript -e "devtools::install_github('toscm/FastRet', Ncpus = parallel::detectCores(), upgrade = FALSE)"

# Prepare Shinyserver
ENV SHINY_LOG_STDERR=1
RUN rm -rf /srv/shiny-server/*
RUN chown -R shiny:shiny /srv/shiny-server
USER shiny
RUN echo "FastRet::FastRet()" > /srv/shiny-server/app.R
CMD ["/usr/bin/shiny-server"]

# hash:sha256:dc25658910a2f1ebf42ed682030dbbf369e613c17f9e280423fc5e86b7533915
FROM registry.codeocean.com/codeocean/stata:16.0-ubuntu18.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends software-properties-common \
    && apt-get purge -y --autoremove software-properties-common \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        imagemagick=8:6.9.7.4+dfsg-16ubuntu6.9 \
    && rm -rf /var/lib/apt/lists/*

COPY stata.lic /usr/local/stata/stata.lic
RUN stata 'ssc install dataout' \
    && stata 'ssc install distinct' \
    && stata 'ssc install egenmore' \
    && stata 'ssc install moremata' # Original versions: 13 Jan 2021 13 Jan 2021 13 Jan 2021 13 Jan 2021

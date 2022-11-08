FROM ubuntu:20.04

LABEL maintainer="Shrey Gandhi" \
      name="ViReassort" \
      version="1.0"

# set env variables
ENV DEBIAN_FRONTEND noninteractive
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/tools/lofreq_star-2.1.2/bin/:/scripts/


# Install packages required by the pipeline
RUN apt update -y \
    && apt upgrade -y  \
    && apt install -y \
    	python \
    	python3-pip \
    	default-jdk \
    	default-jre \
    	wget \
    	autoconf \
    	automake \
    	make \
    	gcc \
    	perl \
    	zlib1g-dev \
    	zlib1g \
    	libcurl4-gnutls-dev \
    	libncurses-dev \
    	libssl-dev \
    	libgsl0-dev \
    	libgsl-dev \
    	libperl-dev \
    	libbz2-dev \
    	liblzma-dev \
    	libtbb2 \
    	libtbb-dev \
    && pip install pysamstats \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*

# Adding tar file containing example files, scripts and tools to run the pipeline. 	
ADD dirs.tar /


# Installing te bioinformatic tools:
RUN chmod +x /tools -R \
    && cd /tools/samtools-1.16.1/ \
    && ./configure \
    && make \
    && make install \
    && mv /tools/tabix-0.2.6/tabix /usr/local/bin/ \
    && cd /tools/bowtie2-2.5.0/ \
    && make \
    && make install \
    && cd /tools/htslib-1.12/ \
    && make \
    && make install \
    && cd /tools/bcftools-1.9/ \
    && autoreconf \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tools/bcftools-1.9 /tools/bowtie2-2.5.0/ /tools/htslib-1.12/ \
    && rm -rf /tools/samtools-1.16.1/ /tools/tabix-0.2.6/ \
    && apt-get clean autoclean \
    && apt-get autoremove -y \
    && rm -rf /var/lib/apt/lists/*
  
 
# Creating a user and modifying permissions.   
RUN useradd -m -d /homes vireassort
RUN mkdir -p /homes \
    && chown -R vireassort:vireassort /homes /Example /tools /scripts \
    && mv /Example /homes

#switch to the dedicated user for contained execution
USER vireassort
WORKDIR /homes

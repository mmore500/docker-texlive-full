#
# mmore500/docker-texlive-full
#
# This is an image with a full TeX Live installation and several
# fonts and tools.
# Source: http://github.com/mmore500/docker-texlive-full/
# Forked from: http://github.com/thomasWeise/docker-texlive-full/
# License: GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
# The license applies to the way the image is built, while the
# software components inside the image are under the respective
# licenses chosen by their respective copyright holders.
#
FROM ubuntu:20.04
MAINTAINER Matthew Andres Moreno <m.more500@gmail.com>

ENV LANG=C.UTF-8
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "Initial update." &&\
    apt-get update &&\
# prevent doc and man pages from being installed
# the idea is based on https://askubuntu.com/questions/129566
    echo "Preventing doc and man pages from being installed." &&\
    printf 'path-exclude /usr/share/doc/*\npath-include /usr/share/doc/*/copyright\npath-exclude /usr/share/man/*\npath-exclude /usr/share/groff/*\npath-exclude /usr/share/info/*\npath-exclude /usr/share/lintian/*\npath-exclude /usr/share/linda/*\npath-exclude=/usr/share/locale/*' > /etc/dpkg/dpkg.cfg.d/01_nodoc &&\
# remove doc files and man pages already installed
    rm -rf /usr/share/groff/* /usr/share/info/* &&\
    rm -rf /usr/share/lintian/* /usr/share/linda/* /var/cache/man/* &&\
    rm -rf /usr/share/man &&\
    mkdir -p /usr/share/man &&\
    find /usr/share/doc -depth -type f ! -name copyright -delete &&\
    find /usr/share/doc -type f -name "*.pdf" -delete &&\
    find /usr/share/doc -type f -name "*.gz" -delete &&\
    find /usr/share/doc -type f -name "*.tex" -delete &&\
    (find /usr/share/doc -type d -empty -delete || true) &&\
    mkdir -p /usr/share/doc &&\
    mkdir -p /usr/share/info &&\
# install utilities
    echo "Installing utilities." &&\
    apt-get install -f -y --no-install-recommends apt-utils &&\
# get and update certificates, to hopefully resolve mscorefonts error
    echo "Get and update certificates for mscorefonts." &&\
    apt-get install -f -y --no-install-recommends ca-certificates &&\
    update-ca-certificates &&\
# install some utilitites and nice fonts, e.g., for Chinese and others
    echo "Installing utilities and nice fonts for Chinese and others." &&\
    apt-get install -f -y --no-install-recommends \
          curl \
          emacs-intl-fonts \
          fontconfig \
          fonts-arphic-bkai00mp \
          fonts-arphic-bsmi00lp \
          fonts-arphic-gbsn00lp \
          fonts-arphic-gkai00mp \
          fonts-arphic-ukai \
          fonts-arphic-uming \
          fonts-dejavu \
          fonts-dejavu-core \
          fonts-dejavu-extra \
          fonts-droid-fallback \
          fonts-guru \
          fonts-guru-extra \
          fonts-liberation \
          fonts-noto-cjk \
          fonts-opensymbol \
          fonts-roboto \
          fonts-roboto-hinted \
          fonts-stix \
          fonts-symbola \
          fonts-texgyre \
          fonts-unfonts-core \
          ttf-wqy-microhei \
          ttf-wqy-zenhei \
          xfonts-intl-chinese \
          xfonts-intl-chinese-big \
          xfonts-wqy &&\
# now the microsoft core fonts
    echo "Installing microsoft core fonts." &&\
    echo "ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true" | debconf-set-selections &&\
    echo "ttf-mscorefonts-installer msttcorefonts/present-mscorefonts-eula note" | debconf-set-selections &&\
    curl --output "/tmp/ttf-mscorefonts-installer.deb" "http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb" &&\
    (apt install -f -y --no-install-recommends "/tmp/ttf-mscorefonts-installer.deb" || true) &&\
    rm -f "/tmp/ttf-mscorefonts-installer.deb" &&\
# we make sure to contain the EULA in our container
    curl --output "/root/mscorefonts-eula" "http://corefonts.sourceforge.net/eula.htm" &&\
    echo "Installing TeX Live and ghostscript and other tools." &&\
# install TeX Live and ghostscript as well as other tools
    apt-get install -f -y --no-install-recommends \
          biber \
          cm-super \
          dvipng \
          fonts-dejavu \
          fonts-dejavu-core \
          fonts-dejavu-extra \
          ghostscript \
          gnuplot \
          make \
          latex-cjk-all \
          latex-cjk-common \
          latex-cjk-chinese \
          latexmk \
          lcdf-typetools \
          lmodern \
          poppler-utils \
          psutils \
          purifyeps \
          python3-pygments \
          t1utils \
          tex-gyre \
          tex4ht \
          texlive-base \
          texlive-bibtex-extra \
          texlive-binaries \
          texlive-extra-utils \
          texlive-font-utils \
          texlive-fonts-extra \
          texlive-fonts-extra-links \
          texlive-fonts-recommended \
          texlive-formats-extra \
          texlive-lang-all \
          texlive-lang-chinese \
          texlive-lang-cjk \
          texlive-latex-base \
          texlive-latex-extra \
          texlive-latex-recommended \
          texlive-luatex \
          texlive-metapost \
          texlive-pictures \
          texlive-plain-generic \
          texlive-pstricks \
          texlive-publishers \
          texlive-science \
          texlive-xetex \
          texlive-bibtex-extra &&\
# delete Tex Live sources and other potentially useless stuff
    echo "Delete TeX Live sources and other useless stuff." &&\
    (rm -rf /usr/share/texmf/source || true) &&\
    (rm -rf /usr/share/texlive/texmf-dist/source || true) &&\
    find /usr/share/texlive -type f -name "readme*.*" -delete &&\
    find /usr/share/texlive -type f -name "README*.*" -delete &&\
    (rm -rf /usr/share/texlive/release-texlive.txt || true) &&\
    (rm -rf /usr/share/texlive/doc.html || true) &&\
    (rm -rf /usr/share/texlive/index.html || true) &&\
# update font cache
    echo "Update font cache." &&\
    fc-cache -fv &&\
# clean up all temporary files
    echo "Clean up all temporary files." &&\
    apt-get clean -y &&\
    rm -rf /var/lib/apt/lists/* &&\
    rm -f /etc/ssh/ssh_host_* &&\
# delete man pages and documentation
    echo "Delete man pages and documentation." &&\
    rm -rf /usr/share/man &&\
    mkdir -p /usr/share/man &&\
    find /usr/share/doc -depth -type f ! -name copyright -delete &&\
    find /usr/share/doc -type f -name "*.pdf" -delete &&\
    find /usr/share/doc -type f -name "*.gz" -delete &&\
    find /usr/share/doc -type f -name "*.tex" -delete &&\
    (find /usr/share/doc -type d -empty -delete || true) &&\
    mkdir -p /usr/share/doc &&\
    rm -rf /var/cache/apt/archives &&\
    mkdir -p /var/cache/apt/archives &&\
    rm -rf /tmp/* /var/tmp/* &&\
    (find /usr/share/ -type f -empty -delete || true) &&\
    (find /usr/share/ -type d -empty -delete || true) &&\
    mkdir -p /usr/share/texmf/source &&\
    mkdir -p /usr/share/texlive/texmf-dist/source &&\
    echo "All done."

ADD scripts /bin/

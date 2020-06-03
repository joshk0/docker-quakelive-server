# Dockerfile to run a linux quake live server
FROM cm2network/steamcmd

# install the quake live server program
ENV HOME /home/steam
ENV QL "${HOME}/Steam/steamapps/common/Quake Live Dedicated Server"
ENV STEAMCMD "${HOME}/steamcmd/steamcmd.sh"
RUN ${STEAMCMD} +login anonymous +app_update 349090 +quit

# copy over the custom game files
WORKDIR /home/steam
ENV PATH ${PATH}:/home/steam/steamcmd

# download the workshop items
COPY workshop.txt "${QL}/baseq3/"
COPY download-workshop.sh ./
RUN ./download-workshop.sh "${QL}/baseq3/workshop.txt"

ENV HOME /home/steam
ENV USER steam
COPY minqlx-plugins "${QL}/minqlx-plugins"
COPY Quake-Live/minqlx-plugins "${QL}/minqlx-plugins"

### ROOT INSTALL FOLLOWS

USER root
RUN apt-get update \
    && apt-get -y install wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV MINQLX_VERSION v0.5.2

RUN apt-get update \
    && apt-get -y --no-install-recommends install \
        build-essential \
        procps \
        net-tools \
        python3-all-dev \
        python3-pip \
        redis-server \
    && pip3 install -r "${QL}/minqlx-plugins/requirements.txt" \
    && pip3 install \
        hiredis \
        pyzmq \
    && wget -O - https://github.com/MinoMino/minqlx/tarball/${MINQLX_VERSION} | tar -C /tmp/ -xvzf - \
    && cd /tmp/MinoMino* \
    && make \
    && cp -v bin/* "${QL}" \
    && apt-get -y --purge remove \
        build-essential \
        python3-all-dev \
    && apt-get -y --purge autoremove \
    && rm -rf /var/lib/apt/lists/*

USER steam
COPY server.sh "${QL}"
COPY server.cfg "${QL}/baseq3/"
RUN mkdir -p .quakelive/27960/baseq3
COPY access.txt .quakelive/27960/baseq3/
COPY mappool_turboca.txt "${QL}/baseq3/"
COPY turboca.factories "${QL}/baseq3/scripts/"

# ports to connect to: 27960 is udp and tcp, 28960 is tcp
EXPOSE 27960 28960
CMD "${QL}/server.sh" 0
FROM ubuntu:16.04 as kmd_builder
LABEL maintainer="Emmanux <infra@komodo.rocks>"

ARG KOMODO_BRANCH
ENV KOMODO_HOME /home/komodo

ENV BUILD_PACKAGES="build-essential pkg-config libc6-dev m4 g++-multilib autoconf libtool ncurses-dev unzip git python python-zmq zlib1g-dev wget libcurl4-openssl-dev bsdmainutils automake curl"

RUN apt update && \
    apt install -y $BUILD_PACKAGES

RUN useradd -u 3003 -m komodo

USER komodo
WORKDIR ${KOMODO_HOME}

RUN git clone https://github.com/jl777/komodo && \
    cd komodo && \
    git checkout ${KOMODO_BRANCH}
RUN cd komodo && ./zcutil/fetch-params.sh
RUN cd komodo && ./zcutil/build.sh -j$(nproc)

USER root
RUN apt remove --purge -y $BUILD_PACKAGES $(apt-mark showauto) && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf ${KOMODO_HOME}/depends

RUN apt update && \
    apt install -y libgomp1 libcurl4-openssl-dev curl

FROM ubuntu:16.04 as kmd_minimal
RUN useradd -u 3003 -m komodo
ENV KOMODO_HOME /home/komodo

COPY --from=kmd_builder  /home/komodo/komodo/src/komodod /bin
COPY --from=kmd_builder  /home/komodo/komodo/src/komodo-cli /bin
COPY --from=kmd_builder  /home/komodo/.zcash-params /home/komodo/.zcash-params

RUN apt update && \
    apt install -y libcurl4-openssl-dev curl libgomp1 git jq && \
    rm -rf /var/lib/apt/lists/*

ADD entrypoint.sh /usr/local/bin
ADD start-komodod.sh /usr/local/bin

COPY blocknotify.sh "${KOMODO_HOME}"/blocknotify.sh
COPY marketmaker "${KOMODO_HOME}"/marketmaker
COPY TxBlast "${KOMODO_HOME}"/TxBlast
COPY start "${KOMODO_HOME}"/start
COPY startblockheight "${KOMODO_HOME}"/startblockheight

USER komodo
WORKDIR "${KOMODO_HOME}"
RUN mkdir ${KOMODO_HOME}/.komodo
RUN mkdir ${KOMODO_HOME}/stats

USER root
RUN chown -R komodo:komodo "${KOMODO_HOME}"

USER komodo

VOLUME ["/home/komodo/.komodo"]
VOLUME ["/home/komodo/stats"]
WORKDIR "${KOMODO_HOME}"

ENTRYPOINT ["entrypoint.sh"]
CMD ["start-komodod.sh"]

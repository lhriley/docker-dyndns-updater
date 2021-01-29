FROM ubuntu:20.04

ENV DYN_USER="dyndns"
ENV DYN_ID="1000"
ENV DYN_HOME="/home/${DYN_USER}"

# Keep the image small by using minimal RUN statements
RUN cd /tmp \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install -y --no-install-recommends apt-utils sudo neovim gnupg2 curl wget openbox xdg-user-dirs libaudio2 libexpat1 libfontconfig libglib2.0-0 libxi6 libxrender1 libffi7 \
    && ln -s /usr/lib/x86_64-linux-gnu/libffi.so.7 /usr/lib/x86_64-linux-gnu/libffi.so.6 \
    && curl -O http://cdn.dyn.com/dynupdater/dynupdater_amd64.deb \
    && dpkg -i ./dynupdater_amd64.deb \
    && cat /etc/apt/sources.list.d/dynupdater.list \
    && sed -iE 's/^deb/deb\ \[trusted\=yes\]/' /etc/apt/sources.list.d/dynupdater.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends -f \
    && apt-get clean \
    && $(rm -rf /var/lib/apt/lists/* /tmp/* /tmp/.* /tmp/*.* || true)

# Create a non-root user
RUN groupadd -g ${DYN_ID} ${DYN_USER} && useradd -m -u ${DYN_ID} -g ${DYN_USER} -G sudo -s /bin/sh ${DYN_USER} \
    && $(echo "ALL ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers) \
    && chown -R ${DYN_ID}:${DYN_ID} ${DYN_HOME}

# Mount the DynDNS config folder as a volume
VOLUME ["${DYN_HOME}/.dynupdater"]

WORKDIR ${DYN_HOME}

USER ${DYN_USER}

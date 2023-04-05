FROM debian:sid-slim

ARG PAYETOOLS_VERSION="23.0.23065.113"

#
# Install the required libraries for Basic PAYE Tools. This list is taken from the linux instructions
# at https://www.gov.uk/government/publications/getting-basic-paye-tools-working-on-linux/getting-basic-paye-tools-working-on-linux
#
RUN apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y glib-2.0 libcomerr2 libfontconfig1 libfreetype6 \
                          libgl1-mesa-glx libgssapi-krb5-2 libk5crypto3 libkrb5-3 \
                          libreadline8 libsqlite3-0 libstdc++6 libx11-6 \
                          libxext6 libxrender1 libxt6 zlib1g libxslt1.1 libxml2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#
# Download and install the tools from HMRC's website. Perform full cleanup to limit image layer size.
#
RUN apt-get update \
    && apt-get install -y curl unzip \
    && cd /root/ \
    && curl -LO https://www.gov.uk/government/uploads/uploaded/hmrc/payetools-rti-${PAYETOOLS_VERSION}-linux.zip \
    && unzip payetools-rti-${PAYETOOLS_VERSION}-linux.zip \
    && /root/payetools-rti-${PAYETOOLS_VERSION}-linux --mode unattended \
    && rm /root/payetools-rti-${PAYETOOLS_VERSION}-linux /root/payetools-rti-${PAYETOOLS_VERSION}-linux.zip \
    && apt-get autoremove -y curl unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#
# For X11 to work through the docker container, we need to tell it to show the screen on a display
# on the host system.
#
ENV DISPLAY=host.docker.internal:0

#
# Avoid running the container as root, so create a new user for normal day to day stuff.
# All of Basic PAYE Tools data will be stored in /home/paye_user/HMRC. Make sure you mount that
# to a volume or host directory so that your data persists.
#
RUN useradd -g users -m paye_user
USER paye_user

ENTRYPOINT ["/opt/HMRC/payetools-rti/rti.linux"]

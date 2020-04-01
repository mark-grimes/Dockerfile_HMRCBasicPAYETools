FROM debian:buster-slim

#
# Install the required libraries for Basic PAYE Tools. This list is taken from the linux instructions
# at https://www.gov.uk/government/publications/getting-basic-paye-tools-working-on-linux/getting-basic-paye-tools-working-on-linux
#
RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get upgrade -y \
    && apt-get install -y libcomerr2:i386 libfontconfig1:i386 libfreetype6:i386 \
                          libgl1-mesa-glx:i386 libgssapi-krb5-2:i386 libk5crypto3:i386 libkrb5-3:i386 \
                          libreadline5:i386 libsqlite3-0:i386 libstdc++6:i386 libx11-6:i386 \
                          libxext6:i386 libxrender1:i386 zlib1g:i386 libxslt1.1:i386 libxml2:i386 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


#
# Download and install the tools from HMRC's website. Perform full cleanup to limit image layer size.
#
RUN apt-get update \
    && apt-get install -y curl unzip \
    && cd /root/ \
    && curl -LO https://www.gov.uk/government/uploads/uploaded/hmrc/payetools-rti-20.0.20083.454-linux.zip \
    && unzip payetools-rti-20.0.20083.454-linux.zip \
    && /root/payetools-rti-20.0.20083.454-linux --mode unattended \
    && rm /root/payetools-rti-20.0.20083.454-linux /root/payetools-rti-20.0.20083.454-linux.zip \
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

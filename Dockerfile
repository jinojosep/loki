FROM registry.access.redhat.com/ubi8/ubi-minimal

ARG VCS_REF
ARG VCS_URL
ARG IMAGE_NAME
ARG IMAGE_DESCRIPTION
ARG IMAGE_DISPLAY_NAME
ARG IMAGE_NAME_ARCH
ARG IMAGE_OWNER
ARG IMAGE_MAINTAINER
ARG IMAGE_VENDOR
ARG IMAGE_VERSION
ARG IMAGE_DESCRIPTION
ARG IMAGE_SUMMARY
ARG IMAGE_OPENSHIFT_TAGS
ARG IMAGE_RELEASE


LABEL org.label-schema.vendor="PROD" \
      org.label-schema.name="$IMAGE_NAME" \
      org.label-schema.description="$IMAGE_DESCRIPTION" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.license="Licensed Materials - Property of IBM" \
      org.label-schema.schema-version="1.0" \
      name="$IMAGE_NAME" \
      maintainer="$IMAGE_MAINTAINER" \
      vendor="$IMAGE_VENDOR" \
      version="$IMAGE_VERSION" \
      release="$VCS_REF" \
      description="$IMAGE_DESCRIPTION" \
      architecture="amd64" \
      summary="$IMAGE_SUMMARY" \
      io.k8s.display-name="$IMAGE_DISPLAY_NAME" \
      io.k8s.description="$IMAGE_DESCRIPTION" \
      io.openshift.tags="$IMAGE_OPENSHIFT_TAGS"
RUN microdnf update -y
RUN INSTALL_PKGS="tar gzip wget" && \
    microdnf --nodocs install $INSTALL_PKGS && \
    microdnf clean all && \
    rm -rf /mnt/rootfs/var/cache/* /mnt/rootfs/var/log/dnf* /mnt/rootfs/var/log/yum.*
RUN wget https://nodejs.org/dist/v14.19.3/node-v14.19.3-linux-x64.tar.gz
RUN tar xf node-v14.19.3-linux-x64.tar.gz
RUN mv node-v14.19.3-linux-x64 node14
ENV PATH=/node14/bin:$PATH
RUN rm -rf /node14/lib/node_modules/npm
RUN microdnf remove gzip && \
    microdnf remove wget && \
    microdnf clean all && \
    rm -rf /mnt/rootfs/var/cache/* /mnt/rootfs/var/log/dnf* /mnt/rootfs/var/log/yum.*

WORKDIR /opt/ibm/server1

COPY DomainVerification.html /opt/ibm/server/DomainVerification.html
COPY DomainVerification-scorecard.html /opt/ibm/server/DomainVerification-scorecard.html
COPY DomainVerification-status.html /opt/ibm/server/DomainVerification-status.html
COPY DomainVerification-prod.html /opt/ibm/server/DomainVerification-prod.html
COPY DomainVerification-scorecard-prod.html /opt/ibm/server/DomainVerification-scorecard-prod.html
COPY DomainVerification-status-prod.html /opt/ibm/server/DomainVerification-status-prod.html
COPY app.js /opt/ibm/server/app.js
COPY views /opt/ibm/server/views
COPY nls /opt/ibm/server/nls
COPY lib /opt/ibm/server/lib
COPY routes /opt/ibm/server/routes
COPY config /opt/ibm/server/config
COPY node_modules /opt/ibm/server/node_modules
COPY public /opt/ibm/server/public

ENV BABEL_DISABLE_CACHE=1
EXPOSE 3000

ENV NODE_ENV production
USER 1001
CMD ["node", "--max-http-header-size=32768" ,"app.js"]

FROM jenkins:2.60.1
MAINTAINER dustin.collins@cyberark.net

# Entrypoint script fetches machine identity and then runs Jenkins using tini, same as source image.
COPY identify.sh /src/identify.sh


# Install summon-conjur provider, simple way to fetch secrets once machine identity is granted.
# https://github.com/conjurinc/summon-conjur
USER root
RUN curl -L -o summon-conjur.tgz \
      https://github.com/conjurinc/summon-conjur/releases/download/v0.2.0/summon-conjur_v0.2.0_linux-amd64.tar.gz \
    && tar -xf summon-conjur.tgz -C /usr/local/bin
# Switch back to Jenkins user, be a good Docker citizen
USER jenkins

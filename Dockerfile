FROM jenkins:2.60.1
MAINTAINER dustin.collins@cyberark.net

# Entrypoint script fetches machine identity and then runs Jenkins using tini, same as source image
COPY identify.sh /src/identify.sh

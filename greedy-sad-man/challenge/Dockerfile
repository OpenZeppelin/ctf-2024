FROM ubuntu:20.04 as scarb

COPY project /project

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

WORKDIR /project

RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    python3.8 \
    python3-pip \
   git 

RUN curl --proto '=https' --tlsv1.2 -sSf https://docs.swmansion.com/scarb/install.sh | bash -s -- -v 2.6.1

# Add Scarb to PATH
ENV PATH="/root/.local/bin:${PATH}"

# Build contracts
RUN scarb build

FROM ghcr.io/openzeppelin/ctf-infra:latest as chroot

# ideally in the future, we can skip the chowns, but for now scarb wants to write the target

USER 1000
WORKDIR /home/user

COPY --chown=user:user . /home/user/challenge/

COPY --from=scarb --chown=user:user /project/target /target

FROM gcr.io/paradigmxyz/ctf/kctf-challenge:latest

VOLUME [ "/chroot", "/tmp" ]

COPY --from=chroot / /chroot

# nsjail help
RUN touch /chroot/bin/kctf_restore_env && touch /chroot/environ

CMD kctf_setup && \
    kctf_persist_env && \
    kctf_drop_privs socat TCP-LISTEN:1337,reuseaddr,fork EXEC:"nsjail --config /nsjail.cfg -- /bin/kctf_restore_env /usr/local/bin/python3 -u challenge/challenge.py"
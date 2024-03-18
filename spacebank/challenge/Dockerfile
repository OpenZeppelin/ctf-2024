FROM ghcr.io/foundry-rs/foundry:latest AS foundry

COPY project /project

# artifacts must be the same path
RUN true && \
    cd /project && \
    forge build --out /artifacts/out --cache-path /artifacts/cache && \
    true

FROM ghcr.io/openzeppelin/ctf-infra:latest as chroot

# ideally in the future, we can skip the chowns, but for now Forge wants to write the cache and broadcast artifacts

USER 1000
WORKDIR /home/user

COPY --chown=user:user . /home/user/challenge/

COPY --from=foundry --chown=user:user /artifacts /artifacts

FROM gcr.io/paradigmxyz/ctf/kctf-challenge:latest

VOLUME [ "/chroot", "/tmp" ]

COPY --from=chroot / /chroot

# nsjail help
RUN touch /chroot/bin/kctf_restore_env && touch /chroot/environ

CMD kctf_setup && \
    kctf_persist_env && \
    kctf_drop_privs socat TCP-LISTEN:1337,reuseaddr,fork EXEC:"nsjail --config /nsjail.cfg -- /bin/kctf_restore_env /usr/local/bin/python3 -u challenge/challenge.py"

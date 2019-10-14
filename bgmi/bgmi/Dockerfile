FROM python:3.6-alpine
LABEL MAINTAINER="trim21<trim21me@gmail.com>"

EXPOSE 8888

ENV LANG C.UTF-8
ENV TRAVIS_CI 1
ENV BGMI_PATH=/bgmi

ARG BGMI_VERSION='dev'
ARG CURRENT_UID='1000'
ARG CURRENT_GID='1000'

ENV USER=bgmi

ENV PIP_ARGS='--no-cache-dir  -i https://mirrors.ustc.edu.cn/pypi/web/simple'

RUN addgroup --gid "$CURRENT_GID" "$USER" &&\
    adduser --uid $CURRENT_UID --disabled-password --ingroup "$USER" --no-create-home "$USER" &&\
    pip install $PIP_ARGS https://github.com/BGmi/bgmi/tarball/$BGMI_VERSION --no-cache-dir

COPY ./entrypoint.sh /entrypoint.sh

VOLUME /bgmi

USER $USER

ENTRYPOINT  ["sh", "/entrypoint.sh"]

CMD ["start_server"]


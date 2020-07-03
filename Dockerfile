FROM golang:1.14-alpine

ENV GO111MODULE=1
ENV LEGO_OWNER="kuskoman"
ENV LEGO_REPO_NAME="lego"
ENV LEGO_BRANCH="hyperone"

RUN apk add make git

RUN git clone "https://github.com/${LEGO_OWNER}/${LEGO_REPO_NAME}.git" -b ${LEGO_BRANCH} --single-branch --depth 1

WORKDIR ${LEGO_REPO_NAME}

RUN make build

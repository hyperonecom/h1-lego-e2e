FROM golang:1.14-alpine as build

ENV GO111MODULE="on"

ARG LEGO_OWNER="kuskoman"
ARG LEGO_REPO_NAME="lego"
ARG LEGO_BRANCH="hyperone"

RUN apk add make git

RUN git clone "https://github.com/${LEGO_OWNER}/${LEGO_REPO_NAME}.git" -b ${LEGO_BRANCH} --single-branch --depth 1 /lego

WORKDIR /lego

RUN make build


FROM golang:1.14-alpine as final

RUN apk add bash

WORKDIR /lego

COPY --from=build /lego/dist/lego /lego
COPY passport.json /root/.h1/
COPY test.sh /lego/

CMD [ "/bin/bash", "test.sh" ]

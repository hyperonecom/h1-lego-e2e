FROM golang:1.14-alpine as build

ENV GO111MODULE="on"

ARG LEGO_OWNER="kuskoman"
ARG LEGO_REPO_NAME="lego"
ARG LEGO_BRANCH="hyperone"

RUN apk add make git

RUN git clone "https://github.com/${LEGO_OWNER}/${LEGO_REPO_NAME}.git" -b ${LEGO_BRANCH} --single-branch --depth 1 /lego

COPY test.sh /lego/

WORKDIR /lego

RUN make build


FROM golang:1.14-alpine as final

WORKDIR /lego

COPY --from=build /lego/dist/lego .
COPY --from=build /lego/test.sh .

CMD [ "/bin/sh", "test.sh" ]

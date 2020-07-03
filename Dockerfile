FROM golang:1.14-alpine as build

ENV GO111MODULE="on"
ENV LEGO_OWNER="kuskoman"
ENV LEGO_REPO_NAME="lego"
ENV LEGO_BRANCH="hyperone"

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

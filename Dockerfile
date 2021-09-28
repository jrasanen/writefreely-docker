## Writefreely Docker image
## Copyright (C) 2019, 2020 Gergely Nagy
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Build image
FROM golang:1.13-alpine as build

ARG WRITEFREELY_VERSION=v0.13.1
ARG WRITEFREELY_FORK=writeas/writefreely

RUN apk add --update nodejs nodejs-npm make g++ git sqlite-dev
RUN npm install -g less less-plugin-clean-css
RUN go get -u github.com/jteeuwen/go-bindata/...

RUN mkdir -p /go/src/github.com/${WRITEFREELY_FORK}
RUN git clone https://github.com/${WRITEFREELY_FORK}.git /go/src/github.com/${WRITEFREELY_FORK} -b ${WRITEFREELY_VERSION}
WORKDIR /go/src/github.com/${WRITEFREELY_FORK}

ENV GO111MODULE=on
RUN make build \
  && make ui
RUN mkdir /stage && \
  cp -R /go/bin \
  /go/src/github.com/${WRITEFREELY_FORK}/templates \
  /go/src/github.com/${WRITEFREELY_FORK}/static \
  /go/src/github.com/${WRITEFREELY_FORK}/pages \
  /go/src/github.com/${WRITEFREELY_FORK}/keys \
  /go/src/github.com/${WRITEFREELY_FORK}/cmd \
  /stage && \
  mv /stage/cmd/writefreely/writefreely /stage

# Final image
FROM alpine:3.11

RUN apk add --no-cache openssl ca-certificates
COPY --from=build --chown=daemon:daemon /stage /writefreely
COPY bin/writefreely-docker.sh /writefreely/

WORKDIR /writefreely
VOLUME /data
EXPOSE 8080

ENTRYPOINT ["/writefreely/writefreely-docker.sh"]

## Writefreely Docker image
## Copyright (C) 2019 Gergely Nagy
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
FROM debian:stable-slim AS build

ARG WRITEFREELY_VERSION=0.11.2

RUN apt update
RUN apt install --no-install-recommends -y curl ca-certificates
RUN curl -L https://github.com/writeas/writefreely/releases/download/v${WRITEFREELY_VERSION}/writefreely_${WRITEFREELY_VERSION}_linux_amd64.tar.gz | tar -C / -xzf -

# Final image
FROM debian:stable-slim AS production

COPY --from=build /writefreely /writefreely
COPY bin/writefreely-docker.sh /writefreely/

WORKDIR /writefreely
VOLUME /data
EXPOSE 8080

ENTRYPOINT ["/writefreely/writefreely-docker.sh"]

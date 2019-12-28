# writefreely-docker

[![Build Status](https://ci.madhouse-project.org/api/badges/algernon/writefreely-docker/status.svg?branch=master)](https://ci.madhouse-project.org/algernon/writefreely-docker)
[![Docker Image](https://img.shields.io/badge/docker-latest-blue?style=flat-square)](https://hub.docker.com/r/algernon/writefreely)

This is a [Docker][docker] image for [WriteFreely][writefreely], set up in a way
that makes it easier to deploy it in production, including the initial setup step.

 [docker]: https://www.docker.com/
 [writefreely]: https://github.com/writeas/writefreely

## Overview

The image is set up to use SQLite for the database, it does not support MySQL
out of the box - but you can always provide your own `config.ini`. The config
file, the database, and the generated keys are all stored on the single volume
the image uses, mounted on `/data`.

The primary purpose of the image is to provide a single-step setup and upgrade
experience, where the initial setup and any upgrades are handled by the image
itself. As such, the image will create a default `config.ini` unless one already
exists, with reasonable defaults. It will also run database migrations, and save
a backup before doing so (which it will delete, if no migrations were
necessary).

## Getting started

To get started, the easiest way to test it out is running the following command:

```shell
docker run -p 8080:8080 -it --rm -v /some/path/to/data:/data \
       algernon/writefreely
```

Then point your browser to `http://localhost:8080`, and you should see
WriteFreely up and running.

## Setup

The image will perform an initial setup, unless the supplied volume already
contains a `config.ini`. Settings can be tweaked via environment variables, of
which you can find a list below. Do note that these environment variables are
*only* used for the initial setup as of this writing! If a configuration file
already exists, the environment variables will be blissfully ignored.

### Environment variables

- `WRITEFREELY_BIND_HOST` and `WRITEFREELY_BIND_PORT` determine the host and port WriteFreely will bind to. Defaults to `0.0.0.0` and `8080`, respectively.
- `WRITEFREELY_SITE_NAME` is the site title one wants. Defaults to "A Writefreely blog".
- `WRITEFREELY_SINGLE_USER`, `WRITEFREELY_OPEN_REGISTRATION`,
  `WRITEFREELY_MIN_USERNAME_LEN`, `WRITEFREELY_MAX_BLOG`,
  `WRITEFREELY_FEDERATION`, `WRITEFREELY_PUBLIC_STATS`, `WRITEFREELY_PRIVATE`,
  `WRITEFREELY_LOCAL_TIMELINE`, and `WRITEFREELY_USER_INVITES` all correspond to
  the similarly named `config.ini` settings. See the [WriteFreely docs][wf:docs]
  for more information about them.

 [wf:docs]: https://writefreely.org/docs/latest/admin/config

# WriteFreely Docker Build

This project builds a Docker image for [WriteFreely](https://github.com/writefreely/writefreely), a minimalist, privacy-focused, and federated blogging platform. The image is uses on Alpine Linux.

## Getting s tarted

To get started, the easiest way to test it out is running the following command:

```bash
docker run -p 8080:8080 -it --rm -v /some/path/to/data:/data \
       jrasanen/writefreely
```

Then point your browser to http://localhost:8080, and you should see WriteFreely up and running.

## Setup

The image will perform an initial setup, unless the supplied volume already contains a config.ini. Settings can be tweaked via environment variables, of which you can find a list below. Do note that these environment variables are only used for the initial setup as of this writing! If a configuration file already exists, the environment variables will be blissfully ignored.

### Environment variables

The following variables will be used to construct the `config.ini` on first start. After it has been configured, you can edit it on the volume.

## General Configuration

- **`WRITEFREELY_BIND_PORT`**: Specifies the port on which the WriteFreely server will listen. Defaults to `8080`.
- **`WRITEFREELY_BIND_HOST`**: Defines the host IP to bind to. Defaults to `0.0.0.0`.
- **`WRITEFREELY_SITE_NAME`**: Sets the name of your WriteFreely site. Used to identify the site in federation.
- **`WRITEFREELY_SITE_DESCRIPTION`**: Provides a short description of your site. This description may be used in federated networks.

## Database Configuration

- **`WRITEFREELY_DATABASE_DATABASE`**: Specifies the type of database used, such as `mysql` or `sqlite3`.
- **`WRITEFREELY_DATABASE_USERNAME`**: The username for the database.
- **`WRITEFREELY_DATABASE_PASSWORD`**: The password for the database.
- **`WRITEFREELY_DATABASE_NAME`**: The name of the database to connect to.
- **`WRITEFREELY_DATABASE_HOST`**: The hostname or IP address of the database server.
- **`WRITEFREELY_DATABASE_PORT`**: The port number on which the database server is running.

## Application Settings

- **`WRITEFREELY_HOST`**: The full URL where the site will be accessible.
- **`WRITEFREELY_SINGLE_USER`**: Set to `true` to run the instance as a single-user blog, otherwise `false`.
- **`WRITEFREELY_OPEN_REGISTRATION`**: Whether or not anyone can register via the landing page
- **`WRITEFREELY_MIN_USERNAME_LEN`**: The minimum length for usernames.
- **`WRITEFREELY_MAX_BLOG`**: Maximum number of blogs a single user can create under one account
- **`WRITEFREELY_FEDERATION`**: Whether or not federation via ActivityPub is enabled
- **`WRITEFREELY_PUBLIC_STATS`**: DWhether or not usage stats are made public via NodeInfo
- **`WRITEFREELY_PRIVATE`**: Set to `true` to make the site private.
- **`WRITEFREELY_LOCAL_TIMELINE`**: Whether or not the instance reader (and the Public option on blogs) is enabled
- **`WRITEFREELY_USER_INVITES`**: Who is allowed to send user invites, if anyone. A blank value disables invites for all users. Valid choices: empty, user, or admin

### Volumes

* `/data`: Directory where WriteFreely stores its data, including database files and configuration.

# h1-lego-e2e

[![Build Status](https://travis-ci.com/hyperonecom/h1-lego-e2e.svg?branch=master)](https://travis-ci.com/hyperonecom/h1-lego-e2e)

This repo contains tests for [Lego](https://github.com/go-acme/lego) integration
with [HyperOne](https://www.hyperone.com/) DNS provider.

## Setting up e2e tests for own repository

### Providing passport file

To setup e2e tests for own repository you have to replace `passport.json.enc` file
with own encrypted passport to be used with [TravisCI](https://travis-ci.com).
You can find more information about it in [travis documentation](https://docs.travis-ci.com/user/encrypting-files/).

```shell
gem install travis
travis login --com
travis encrypt-file passport.json
```

Travis should automatically detect repository you are using and update secrets on their side.

### Specifying github repository and branch

You use this project with custom github repository and branch.
To do that provide custom [build arguments](https://docs.docker.com/engine/reference/commandline/build/#options)
when building the image.

Aviable arguments:

- `LEGO_OWNER`- github account with Lego repository
- `LEGO_REPO_NAME`- name of repository containing Lego
- `LEGO_BRANCH`- branch to be pulled when building image

### Specifying domains to be checked

You are able to override default domain to be checked by passing
`BASE_URL` and `ALIAS_URL` environment variables to container.

Example:

```shell
docker run -e BASE_URL="you-custom-url.domain" -e ALIAS_URL="alias.domain" <image tag/id>
```

The application issues certificates for:

- `"$BASE_URL"`
- `"*.$BASE_URL"`
- `"$ALIAS_URL"`
- `"*.$ALIAS_URL`

### Testing alias mode

The application provides `$ALIAS_URL` variable for checking alias mode.
To do it create [CNAME](https://en.wikipedia.org/wiki/CNAME_record) recordset on `_acme-challenge.$ALIAS_URL.`
with record containing domain which has to be used for obtaining certificate.
To avoid false-positives make sure that service account you are using with the application has NO permission
to modify zone resources for alias domain (view permission may be required).

Testing alias mode is possible thanks to `LEGO_EXPERIMENTAL_CNAME_SUPPORT=true` environment variable.

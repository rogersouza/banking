FROM elixir:1.9.1-alpine as build

RUN apk add --update \
  && apk add -u musl musl-dev musl-utils build-base

RUN apk add --update --yes postgresql-client

RUN mkdir /app 

RUN mix local.hex --force && \
    mix local.rebar --force

ARG mix_env=prod

ENV MIX_ENV=${mix_env}

COPY . /app

WORKDIR /app

RUN mix deps.get
RUN mix deps.compile

# Only runs mix release if in production mode
RUN if [ "$MIX_ENV" == "prod" ]; then \
      mix release; \
    else \
      echo "[MIX_ENV=${MIX_ENV}] not running mix release"; \
    fi

FROM alpine:3.9 as app

RUN apk add --update bash openssl
RUN mkdir /app

WORKDIR /app

COPY --from=build /app/_build/prod/rel/api ./

ENV HOME=/app

CMD bin/api eval Db.Release.migrate && bin/api start  
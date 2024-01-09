FROM ruby:3.3-alpine

RUN mkdir /app
WORKDIR /app
RUN apk --update add less git curl
COPY Gemfile Gemfile.lock ./
RUN apk add --no-cache freetds-dev libc6-compat && ln -s /lib/libc.musl-x86_64.so.1 /lib/ld-linux-x86-64.so.2
RUN apk --update add --virtual gem-build build-base libcurl curl-dev freetds && \
    bundle install --jobs 20 --retry 5 && \
    apk del gem-build
EXPOSE 9000
CMD ["tail",  "-f", "/dev/null"]
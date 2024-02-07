FROM ruby:3.2-alpine

RUN mkdir /app
WORKDIR /app
RUN apk --update add less git curl
COPY Gemfile Gemfile.lock ./
RUN apk add bash git
RUN apk --update add --virtual gem-build build-base libcurl curl-dev && \
    bundle install --jobs 20 --retry 5 && \
    apk del gem-build
EXPOSE 9000
CMD ["tail",  "-f", "/dev/null"]
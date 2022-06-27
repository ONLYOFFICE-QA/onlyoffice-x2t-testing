FROM ruby:3.1
ENV S3_KEY ""
ENV S3_PRIVATE_KEY ""
ENV PALLADIUM_TOKEN ""
RUN mkdir -pv ~/.s3 && \
    echo $S3_KEY > ~/.s3/key && \
    echo $S3_PRIVATE_KEY > ~/.s3/private_key
RUN apt-get update -y && apt-get install -y libmagic-dev
RUN gem install bundler
RUN gem update --system
RUN mkdir /testing-x2t
WORKDIR /testing-x2t
ADD . /testing-x2t
RUN gem install bundler
RUN bundler install

# set base image (host OS)
FROM python:3.8

RUN rm /bin/sh && ln -s /bin/bash /bin/sh

RUN apt-get -y update
RUN apt-get install -y curl nano wget nginx git

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Mongo
RUN ln -s /bin/echo /bin/systemctl
RUN wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
RUN echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian buster/mongodb-org/4.4 main" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list

# Add Bullseye repository for libssl1.1
RUN echo "deb http://deb.debian.org/debian bullseye main" >> /etc/apt/sources.list

RUN apt-get -y update
RUN apt-get install -y mongodb-org libssl1.1

# Remove Bullseye repository after installing libssl1.1
RUN sed -i '/bullseye/d' /etc/apt/sources.list

# Install Yarn
RUN apt-get install -y yarn

# Install PIP
RUN python -m ensurepip --upgrade
RUN pip install --upgrade pip

ENV ENV_TYPE staging
ENV MONGO_HOST mongo
ENV MONGO_PORT 27017

ENV PYTHONPATH=$PYTHONPATH:/src/

# copy the dependencies file to the working directory
COPY src/requirements.txt .

# install dependencies
RUN pip install -r requirements.txt

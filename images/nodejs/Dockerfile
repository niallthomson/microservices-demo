# Package Stage
FROM node:12-alpine

RUN apk update && \
    apk add --no-cache curl python3 alpine-sdk

WORKDIR /app

# Only copy the package.json file to work directory
COPY package.json .
# Install all Packages
RUN npm install
# Copy all other source code to work directory
ADD . /app
# TypeScript
RUN npm run build

ENTRYPOINT [ "node", "index.js" ]
# Package Stage
FROM node:14-alpine

RUN apk update && apk upgrade && \
    apk add --no-cache curl

WORKDIR /app

# Only copy the package.json file to work directory
COPY package.json .
# Install all Packages
RUN npm install
# Copy all other source code to work directory
ADD . /app
# TypeScript
RUN npm run build

CMD [ "npm", "start" ]
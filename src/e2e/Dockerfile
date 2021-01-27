FROM markadams/chromium-xvfb

WORKDIR /usr/src/app

RUN apt-get update && apt-get install -y gpg \
    && curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs gpg \
    && rm -rf /var/lib/apt/lists

WORKDIR /app

RUN groupadd -r app && useradd -r -d /app -g app -G audio,video app \
	&& mkdir -p /app && chown -R app:app /app

USER app

ADD . /app

RUN npm install

CMD [ "npm", "test" ]
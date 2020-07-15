FROM loadimpact/k6:latest

ENV WATCHN_BASE_URL ""
ENV WATCHN_REGION ""
ENV WATCHN_TARGET ""
ENV K6_OUT ""

COPY js/ /js

CMD [ "run", "/js/script.js"]
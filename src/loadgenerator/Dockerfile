FROM loadimpact/k6:latest

ENV WATCHN_BASE_URL ""
ENV WATCHN_REGION ""
ENV WATCHN_TARGET ""
ENV WATCHN_K6_OUT "influxdb=$influx_url"

COPY js/ /js

CMD [ "run", "/js/script.js"]
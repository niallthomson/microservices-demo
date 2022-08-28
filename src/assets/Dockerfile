FROM nginx:1.23
EXPOSE 8080
COPY default.conf /etc/nginx/conf.d/default.conf
COPY mime.types /etc/nginx/mime.types
COPY public/ /usr/share/nginx/html

RUN chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid

USER nginx
FROM nginx:latest
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./snippets/* /etc/nginx/snippets/

WORKDIR /app
RUN chown -R nginx:nginx /app /var/cache/nginx /var/log/nginx /etc/nginx/conf.d /etc/nginx/ssl
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
USER nginx

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
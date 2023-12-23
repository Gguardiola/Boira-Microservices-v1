FROM nginx:latest
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./snippets/* /etc/nginx/snippets/

WORKDIR /app
RUN chown -R nginx:nginx /app && chmod -R 755 /app && \
        chown -R nginx:nginx /var/cache/nginx && \
        chown -R nginx:nginx /var/log/nginx && \
        chown -R nginx:nginx /etc/nginx/ssl
        chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
        chown -R nginx:nginx /var/run/nginx.pid
USER nginx

EXPOSE 80
EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
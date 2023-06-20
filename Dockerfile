FROM jakejarvis/hugo-extended as build

WORKDIR /site
ADD . .
RUN hugo

FROM caddy:alpine
COPY --from=build /site/public /var/www/web
ADD Caddyfile /etc/caddy/Caddyfile
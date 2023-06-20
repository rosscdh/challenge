FROM jakejarvis/hugo-extended as build

WORKDIR /site
ADD . .
RUN hugo

FROM caddy:alpine
COPY --from=build /site/public /var/www/hypercare
ADD Caddyfile /etc/caddy/Caddyfile
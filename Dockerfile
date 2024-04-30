FROM klakegg/hugo:latest-ext as hugo
COPY ./www /site
WORKDIR /site
RUN hugo --config ./config.toml
#Copy static files to Nginx - use old version with CVEs
FROM nginx:1-alpine3.18
COPY --from=hugo /site/public /usr/share/nginx/html
WORKDIR /usr/share/nginx/html
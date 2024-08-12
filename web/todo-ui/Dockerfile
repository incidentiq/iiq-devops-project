FROM node:20 AS build
COPY package.json package.json
RUN npm i
COPY ./src src
COPY ./public public
RUN npm run build

FROM nginx:bookworm
COPY --from=build build /usr/share/nginx/html

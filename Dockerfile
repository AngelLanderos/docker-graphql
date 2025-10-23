# Stage: dev-deps (cache para builder)
FROM node:19-alpine3.15 AS dev-deps
WORKDIR /app

# copiar lockfile también
COPY package.json yarn.lock ./

# activar corepack y usar yarn (asegura que yarn exista)
RUN yarn install --frozen-lockfile

# Stage: builder
FROM node:19-alpine3.15 AS builder
WORKDIR /app
COPY --from=dev-deps /app/node_modules ./node_modules
COPY . .
# RUN yarn test
RUN yarn build

# Stage: prod-deps (solo deps de producción)
FROM node:19-alpine3.15 AS prod-deps
WORKDIR /app
COPY package.json yarn.lock ./
RUN yarn install --production --frozen-lockfile

# Stage: prod (final)
FROM node:19-alpine3.15 AS prod
EXPOSE 3000
WORKDIR /app

# acepta build arg para APP_VERSION
ARG APP_VERSION=dev
ENV APP_VERSION=${APP_VERSION}

COPY --from=prod-deps /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

CMD ["node","dist/main.js"]







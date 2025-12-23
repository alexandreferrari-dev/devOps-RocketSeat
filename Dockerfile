# Stage 1: Build
FROM node:18-alpine3.19 AS build

WORKDIR /usr/src/app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn install

COPY . .

RUN yarn run build

# Stage 2: Deps de produção
FROM node:18-alpine3.19 AS deps

WORKDIR /usr/src/app

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn

RUN yarn plugin import workspace-tools && \
    yarn workspaces focus --all --production

# Stage 3: Produção (IMAGEM FINAL)
FROM node:18-alpine3.19

WORKDIR /usr/src/app

# ⚡ ADICIONE ESTA LINHA!
RUN corepack enable

# Copiar apenas o necessário para rodar
COPY --from=build /usr/src/app/dist ./dist
COPY --from=deps /usr/src/app/node_modules ./node_modules
COPY package.json ./

EXPOSE 3000

CMD ["node", "dist/main.js"]
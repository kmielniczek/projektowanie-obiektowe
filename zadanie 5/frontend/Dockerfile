FROM node:20-alpine AS builder

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --silent

COPY public src index.html eslint.config.js \
    tsconfig.json tsconfig.app.json tsconfig.node.json vite.config.ts ./

RUN npm run build

USER node

EXPOSE 5173

CMD ["npm", "run", "preview", "--", "--host", "--port", "5173"]

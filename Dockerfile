FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm config set maxsockets 5 && \
    npm config set fetch-retries 5 && \
    npm config set fetch-retry-factor 20 && \
    npm config set fetch-retry-mintimeout 20000 && \
    npm config set fetch-retry-maxtimeout 120000 && \
    npm config set fetch-timeout 300000 && \
    (npm ci --legacy-peer-deps --no-audit --no-fund || npm install --legacy-peer-deps --no-audit --no-fund)
COPY . .
RUN rm -rf dist *.tsbuildinfo node_modules/.vite
RUN echo "⏳ Compilando..."; \
      start=$(date +%s); \
      npm run build; \
      end=$(date +%s); \
      echo "⏱️ La compilación tardó $((end - start)) segundos."

FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf
EXPOSE 3000
CMD ["nginx", "-g", "daemon off;"]

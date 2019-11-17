# Builder stage
FROM node:12-alpine AS builder
WORKDIR /app

COPY .npmrc ./
COPY package*.json ./
COPY tsconfig*.json ./
COPY src ./src

RUN npm install
ENV NODE_ENV=production
RUN npm run build

# Runtime stage (production part)
FROM node:12-alpine AS runtime
RUN apk --no-cache add ca-certificates
WORKDIR /app

COPY .npmrc ./
COPY package*.json ./
COPY --from=builder /app/dist/ dist/
COPY --from=gcr.io/berglas/berglas:latest /bin/berglas /bin/berglas

RUN npm install --only=production

ENTRYPOINT exec /bin/berglas exec -- npm start
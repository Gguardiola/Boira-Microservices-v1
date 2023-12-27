FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV production
ENV AUTH_SERVICE_HOST=http://auth-service:${PORT}
ENV PORT=${PORT}

RUN addgroup -S nodejs-api-goodgifts-v1 && adduser -S nodejs-api-goodgifts-v1 -G nodejs-api-goodgifts-v1

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R nodejs-api-goodgifts-v1:nodejs-api-goodgifts-v1 /app

USER nodejs-api-goodgifts-v1

EXPOSE 5000

CMD ["npm", "start"]
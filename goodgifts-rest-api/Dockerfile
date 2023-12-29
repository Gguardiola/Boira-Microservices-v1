FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV production
ENV AUTH_SERVICE_HOST=${AUTH_SERVICE_HOST}
ENV PORT=${PORT}

ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV POSTGRES_DB=${POSTGRES_DB}
ENV POSTGRES_HOST=${POSTGRES_HOST}

RUN addgroup -S nodejs-api-goodgifts-v1 && adduser -S nodejs-api-goodgifts-v1 -G nodejs-api-goodgifts-v1

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R nodejs-api-goodgifts-v1:nodejs-api-goodgifts-v1 /app

USER nodejs-api-goodgifts-v1

EXPOSE 5000

CMD ["npm", "start"]
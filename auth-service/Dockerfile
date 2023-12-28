FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV production
ENV JWT_SECRET=${JWT_SECRET}
ENV PORT=${PORT}

ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV POSTGRES_DB=${POSTGRES_DB}
ENV POSTGRES_HOST=${POSTGRES_HOST}



RUN addgroup -S nodejs-auth && adduser -S nodejs-auth -G nodejs-auth

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R nodejs-auth:nodejs-auth /app

USER nodejs-auth

EXPOSE 3001

CMD ["npm", "start"]
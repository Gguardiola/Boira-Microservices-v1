FROM node:18-alpine

WORKDIR /app

ENV NODE_ENV production

RUN addgroup -S nodejs-auth && adduser -S nodejs-auth -G nodejs-auth

COPY package*.json ./

RUN npm install

COPY . .

RUN chown -R nodejs-auth:nodejs-auth /app

USER nodejs-auth

EXPOSE 3001

CMD ["npm", "start"]
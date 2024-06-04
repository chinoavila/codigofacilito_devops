FROM node:18-bookworm

WORKDIR /app

COPY ./package.json /app/package.json

RUN npm install

COPY ./src/ /app/src

CMD ["npm", "run", "dev"]
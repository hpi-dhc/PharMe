# Note: this Dockerfile is meant to be run from the project root as we need to
# add local modules which are outside of the context of the `anni` directory.
# You can build this image by running `docker build -t anni -f
# ./anni/Dockerfile .` from the project root.

ARG BASE_IMAGE=node:16-alpine


# Dependencies
FROM ${BASE_IMAGE} AS deps
# Check https://github.com/nodejs/docker-node/tree/b4117f9333da4138b03a546ec926ef50a31506c3#nodealpine
# to understand why libc6-compat might be needed.
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY ./package.json ./yarn.lock ./
COPY ./anni/package.json ./anni/package.json
RUN yarn workspace anni --frozen-lockfile install


# Build
FROM ${BASE_IMAGE} AS builder
WORKDIR /app
COPY --from=deps /app/node_modules ./node_modules
COPY --from=deps /app/anni/node_modules ./anni/node_modules
COPY . .
RUN yarn workspace anni run build


# Run
FROM ${BASE_IMAGE} AS runner
WORKDIR /app

RUN addgroup --system --gid 1001 nodejs
RUN adduser --system --uid 1001 nextjs

COPY --from=builder /app/anni/package.json ./anni/package.json

COPY --from=builder --chown=nextjs:nodejs /app/anni/.next/standalone ./anni/
COPY --from=builder --chown=nextjs:nodejs /app/anni/.next/static ./anni/anni/.next/static

USER nextjs

EXPOSE 3000
ENV PORT 3000

CMD [ "node", "anni/anni/server.js"]

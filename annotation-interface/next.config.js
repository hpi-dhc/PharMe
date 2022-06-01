const path = require('path')

/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: true,
    experimental: {
        outputStandalone: true,
        outputFileTracingRoot: path.join(__dirname, '../')
    }
}

module.exports = nextConfig

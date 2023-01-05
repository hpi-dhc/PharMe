const path = require('path')

/** @type {import('next').NextConfig} */
const nextConfig = {
    reactStrictMode: false,
    experimental: {
        outputStandalone: true,
        outputFileTracingRoot: path.join(__dirname, '../')
    }
}

module.exports = nextConfig

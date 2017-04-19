require('dotenv').config();
const path = require('path');
const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin')
const SWPrecacheWebpackPlugin = require('sw-precache-webpack-plugin');

module.exports = {
  entry: './src/main.js',
  output: {
    filename: 'bundle.js',
  },
  devServer: {
    inline: true,
    historyApiFallback: true,
  },
  module: {
    rules: [{
      test: /\.elm$/,
      exclude: [/elm-stuff/, /node_modules/],
      loader: 'elm-webpack-loader' +
        (process.env.NODE_ENV !== 'production' ? '?+debug' : ''),
    }],
  },
  plugins: [
    new SWPrecacheWebpackPlugin({
      cacheId: "invoizr",
      filename: "service-worker.js",
      staticFileGlobs: [
        'style.css',
        'index.html',
        'bundle.js'
      ],
      mergeStaticsConfig: true,
    })
  ],
};

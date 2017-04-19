require('dotenv').config();
const path = require('path');
const webpack = require('webpack');
const CopyWebpackPlugin = require('copy-webpack-plugin')

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
    new CopyWebpackPlugin([
      { from: './src/service-worker.js', to: './service-worker.js'},
    ])
  ],
};

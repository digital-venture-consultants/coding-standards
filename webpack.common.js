const DefinePlugin = require("webpack")["DefinePlugin"];
const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const HtmlWebpackPlugin = require("html-webpack-plugin");
const execa = require("execa");
const path = require("path");
const FaviconsWebpackPlugin = require("favicons-webpack-plugin");
const CopyPlugin = require("copy-webpack-plugin");

const versionName = "v" + require("./package.json").version;
const versionCode = 1;
const gitHash = execa.sync("git", ["rev-parse", "--short", "HEAD"]).stdout;
const gitNumCommits = Number(execa.sync("git", ["rev-list", "HEAD", "--count"]).stdout);
const gitDirty = execa.sync("git", ["status", "-s", "-uall"]).stdout.length > 0;

module.exports = {
  entry: "./src/index.js",
  mode: "development",
  output: {
    path: path.resolve(__dirname, "./dist"),
    filename: "index_bundle.js",
  },
  devtool: "inline-source-map",
  devServer: {
    contentBase: "./dist",
  },
  module: {
    rules: [
      {
        test: /\.s[ac]ss$/i,
        use: [
          // Creates `style` nodes from JS strings
          "style-loader",
          // Translates CSS into CommonJS
          "css-loader",
          // Compiles Sass to CSS
          "sass-loader",
        ],
      },
      {
        test: /\.css$/i,
        use: [MiniCssExtractPlugin.loader, "css-loader"],
      },
    ],
  },
  plugins: [
    new CopyPlugin({
      patterns: [
        { from: "./src/profile.png" }
      ],
    }),
    new MiniCssExtractPlugin(),
    new DefinePlugin({
      PRODUCTION: JSON.stringify(true),
      VERSION: JSON.stringify({
        name: versionName,
        code: versionCode,
        gitHash: gitHash,
        gitNumCommits: gitNumCommits,
        dirty: gitDirty,
      }),
      TIMESTAMP: JSON.stringify(Date.now())
    }),
    new FaviconsWebpackPlugin({
      logo: "./src/favicon.png"
    }),
    new HtmlWebpackPlugin({
      template: "./src/index.html"
    })
  ],
};

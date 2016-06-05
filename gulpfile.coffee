gulp = require "gulp"

#コンパイル
coffee = require "gulp-coffee"
jade = require "gulp-jade"
stylus = require "gulp-stylus"
nib = require "nib"
autoprefixer = require "gulp-autoprefixer"

#ファイル監視、更新
notify = require "gulp-notify"
plumber = require "gulp-plumber"
cache = require "gulp-cached"
browserSync = require "browser-sync"

#ファイル結合、管理
concat = require "gulp-concat"
uglify = require "gulp-uglify"
rename = require "gulp-rename"

#css整形
cssbeautify = require "gulp-cssbeautify"
csscomb = require "gulp-csscomb"

#yaml
vinylYamlData = require "vinyl-yaml-data"
deepExtend = require "deep-extend-stream"

#bower
bower = require "gulp-bower"

#開発ディレクトリ
dev =
  jade: "./dev/"
  stylus: "./dev/"
  coffee: "./dev/"
  yaml:   "./dev/"

#公開ディレクトリ
pub =
  html: "./public/"
  css:  "./public/"
  js:   "./public/"

#yamlデータ
locals = {}

#yaml読み込みタスク
gulp.task "yaml", ->
  return gulp.src "#{dev.yaml}config.yml"
  .pipe vinylYamlData()
  .pipe deepExtend(locals)

#jadeタスク
gulp.task "jade", ["yaml"], ->
  return gulp.src [
    "#{dev.jade}**/*.jade",
    "!#{dev.jade}**/_*.jade"
  ]
  # .pipe cache "jade"
  .pipe plumber
    errorHandler: notify.onError "Error: <%= error.message %>"
  .pipe jade
    pretty: true,
    locals: locals
  .pipe gulp.dest "#{pub.html}"
  .on "end", browserSync.reload

#stylタスク
gulp.task "stylus", ->
  return gulp.src [
    "#{dev.stylus}**/*.styl",
    "!#{dev.stylus}**/_*.styl"
  ]
  .pipe cache "stylus"
  .pipe plumber
    errorHandler: notify.onError "Error: <%= error.message %>"
  .pipe stylus
    use: nib(),
    compress: true,
    linenos: false
   #css整形
  .pipe csscomb()
  .pipe cssbeautify
    indent: '  ',
    openbrace: 'end-of-line',
    autosemicolon: true
  .pipe gulp.dest "#{pub.css}"
  .on "end", browserSync.reload

#coffeeタスク
gulp.task "coffee", ->
  return gulp.src "#{dev.coffee}**/*.coffee"
  .pipe cache "coffee"
  .pipe plumber
    errorHandler: notify.onError "Error: <%= error.message %>"
  .pipe coffee
    bare: true
  .pipe gulp.dest "#{pub.js}"
  .on "end", browserSync.reload

#jsファイル結合
gulp.task "concat_ie", ->
  return gulp.src "#{dev.coffee}ie/*.js"
    .pipe concat "ie.js"
    .pipe uglify()
    .pipe rename
      extname: ".min.js"
    .pipe gulp.dest "#{pub.js}"

#ブラウザ
gulp.task "browser", ->
  browserSync
    port: 8888,
    server:
      baseDir: "./public"
    open: false,
    notify: false

# bower
gulp.task "jquery", ->
  gulp.src "./bower_components/jquery/dist/jquery.min.js"
    .pipe gulp.dest "./public"

gulp.task "reset-css", ->
  gulp.src "./bower_components/reset-css/reset.css"
    .pipe gulp.dest "./public"

#監視(jade, stylus, coffee)
gulp.task "watch", ["browser","jquery","reset-css"], ->
  gulp.watch "#{dev.jade}**/*.jade", ["jade"]
  gulp.watch "#{dev.yaml}**/*.yml", ["jade"]
  gulp.watch "#{dev.stylus}**/*.styl", ["stylus"]
  gulp.watch "#{dev.coffee}**/*.coffee", ["coffee"]

#デフォルトタスク
gulp.task "default", ["watch"]
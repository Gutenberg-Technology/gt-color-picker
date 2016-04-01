gulp = require 'gulp'
coffee = require 'gulp-coffee'
sass = require 'gulp-sass'
concat = require 'gulp-concat'
prefix = require 'gulp-autoprefixer'
plumber = require 'gulp-plumber'
coffeelint = require 'gulp-coffeelint'
sassLint = require 'gulp-sass-lint'
templateCache = require 'gulp-angular-templatecache'
htmlmin = require 'gulp-htmlmin'
cleaning = require 'gulp-initial-cleaning'


cleaning(
    tasks: ['default']
    folders: ['dist']
)

gulp.task 'coffee', ->
    gulp.src(['src/**/*.coffee'])
    .pipe(plumber())
    .pipe(coffeelint('coffeelint.json'))
    .pipe(coffeelint.reporter())
    .pipe(coffee(bare: true))
    .pipe(concat('app.js'))
    .pipe(gulp.dest('./dist'))

gulp.task 'sass-lint', ->
    gulp.src('src/**/*.sass')
    .pipe(plumber())
    .pipe(sassLint())
    .pipe(sassLint.format())
    .pipe(sassLint.failOnError())

gulp.task 'sass', ['sass-lint'], ->
    gulp.src('src/gtColorPicker.sass')
    .pipe(plumber())
    .pipe(sass().on('error', sass.logError))
    .pipe(prefix(["last 2 version", "> 5%", "ie 10", "ie 9"]))
    .pipe(gulp.dest('./dist'))

# Template
gulp.task 'template', ->
    gulp.src('src/**/*.html')
    .pipe(plumber())
    .pipe(htmlmin(
        collapseWhitespace: true
        removeComments: true
    ))
    .pipe(templateCache(
        root: '/'
        module: 'gt.colorpicker'
    ))
    .pipe(gulp.dest('dist/'))

gulp.task 'concat', ['coffee', 'template'], ->
    gulp.src('dist/*.js')
    .pipe(concat('gtColorPicker.js'))
    .pipe(gulp.dest('./dist'))

gulp.task 'default', ['sass', 'concat']

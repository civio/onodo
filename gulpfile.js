var gulp = require('gulp');
var gulpif = require('gulp-if');
var sprity = require('sprity');

// generate home-sprite.png and _home-sprite.scss
gulp.task('sprites', function () {
  return sprity.src({
    src: './app/assets/images/sprites/**/*.png',
    style: './_sprites.scss',
    split: true,
    orientation: 'binary-tree',
    processor: 'sass', // make sure you have installed sprity-sass
  })
  .pipe(gulpif('*.png', gulp.dest('./public/images'), gulp.dest('./app/assets/stylesheets/scss/')));
});
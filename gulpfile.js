var gulp = require('gulp');
var gulpif = require('gulp-if');
var sprity = require('sprity');

// generate home-sprite.png and _home-sprite.scss
gulp.task('sprites', function () {
  return sprity.src({
    src: './app/assets/images/sprites/**/*.png',
    style: './stylesheets/scss/_sprites.scss',
    // Use split option to generate une sprite per folder
    // https://github.com/sprity/sprity#how-to-use-split-option
    split: true,
    // Make sure you have installed sprity-sass
    // https://www.npmjs.com/package/sprity-sass
    processor: 'sass',
    // Use binary-tree orientation to improve sprite size
    orientation: 'binary-tree',
    // Add retina 2x support
    // https://github.com/sprity/sprity#how-to-specify-dimensions
    dimension: [{
        ratio: 1, dpi: 72
      }, {
        ratio: 2, dpi: 192
      }],
  })
  .pipe(gulpif('*.png', gulp.dest('./public/images'), gulp.dest('./app/assets')));
});
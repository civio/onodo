module.exports = function (grunt) {
  // Configure grunt
  grunt.initConfig({
    sprite:{
      sprite_large: {
        src: './app/assets/images/sprites/main-2x/*.png',
        dest: './public/images/sprites-2x.png',
        destCss: './app/assets/stylesheets/scss/_sprites-2x.scss',
        imgPath: '/images/sprites-2x.png',
        'engineOpts': {
          'imagemagick': true
        },
      },
      sprite: {
        src: './app/assets/images/sprites/main/*.png',
        dest: './public/images/sprites.png',
        destCss: './app/assets/stylesheets/scss/_sprites.scss',
        imgPath: '/images/sprites.png',
        'engineOpts': {
          'imagemagick': true
        },
      }
    }
  });

  // Load in `grunt-spritesmith`
  grunt.loadNpmTasks('grunt-spritesmith');
};
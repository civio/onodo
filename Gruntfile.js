// Run task as `grunt sprite`
module.exports = function (grunt) {
  // Configure grunt
  grunt.initConfig({
    sprite:{
      
      sprite: {
        src: './app/assets/images/sprites/main/*.png',
        dest: './public/images/sprites.png',
        destCss: './app/assets/stylesheets/scss/_sprites.scss',
        imgPath: '/images/sprites.png',
        'engineOpts': {
          'imagemagick': true
        },
      },
      sprite_home: {
        src: './app/assets/images/sprites/home/*.png',
        dest: './public/images/sprites-home.png',
        destCss: './app/assets/stylesheets/scss/_sprites-home.scss',
        imgPath: '/images/sprites-home.png',
        'engineOpts': {
          'imagemagick': true
        },
      },
      sprite_large: {
        src: './app/assets/images/sprites/main-2x/*.png',
        dest: './public/images/sprites-2x.png',
        destCss: './app/assets/stylesheets/scss/_sprites-2x.scss',
        imgPath: '/images/sprites-2x.png',
        'engineOpts': {
          'imagemagick': true
        },
      },
      sprite_home_large: {
        src: './app/assets/images/sprites/home-2x/*.png',
        dest: './public/images/sprites-home-2x.png',
        destCss: './app/assets/stylesheets/scss/_sprites-home-2x.scss',
        imgPath: '/images/sprites-home-2x.png',
        'engineOpts': {
          'imagemagick': true
        },
      },
    }
  });

  // Load in `grunt-spritesmith`
  grunt.loadNpmTasks('grunt-spritesmith');
};
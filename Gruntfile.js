module.exports = function (grunt) {

  // Configure grunt
  grunt.initConfig({

    // Configure spritesheets
    sprite:{
      sprite: {
        src: './app/assets/images/main/*.png',
        dest: './public/images/sprites.png',
        destCss: './app/assets/stylesheets/scss/_sprites.scss',
        imgPath: '/images/sprites.png',
        retinaSrcFilter: './app/assets/images/main/*@2x.png',
        retinaDest: './public/images/sprites@2x.png',
        retinaImgPath: '/images/sprites@2x.png',
        'engineOpts': {
          'imagemagick': true
        },
      },
      sprite_home: {
        src: './app/assets/images/home/*.png',
        dest: './public/images/sprites-home.png',
        destCss: './app/assets/stylesheets/scss/_sprites-home.scss',
        imgPath: '/images/sprites-home.png',
        retinaSrcFilter: './app/assets/images/home/*@2x.png',
        retinaDest: './public/images/sprites-home@2x.png',
        retinaImgPath: '/images/sprites-home@2x.png',
        'engineOpts': {
          'imagemagick': true
        },
      }
    }
  });

  // Generate spritesheet with `grunt sprite`
  grunt.loadNpmTasks('grunt-spritesmith');
};
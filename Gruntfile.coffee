module.exports = (grunt) ->
  grunt.initConfig
    pkg: grunt.file.readJSON 'package.json'
    coffee:
      compile:
        cwd: 'src/'
        expand: true,
        src: ['*.coffee']
        dest: 'dist/'
        ext: '.js'

    coffeeredux:
      compile:
        cwd: 'src/'
        expand: true,
        src: ['*.coffee']
        dest: 'dist/'
        ext: '.js'

    watch:
      coffee:
        files: 'src/*.coffee'
        tasks: 'coffee'
      coffeeredux:
        files: 'src/*.coffee'
        tasks: 'coffee'

  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-coffee-redux'
  grunt.loadNpmTasks 'grunt-contrib-watch'
#global module:false
module.exports = (grunt) ->
  
  # Project configuration.
  grunt.initConfig
    watch:
      files: ["source/**/*.coffee"]
      tasks: ["coffee", "jshint"]

    coffee:
      compile:
        files:
          "lib/sococo.js": "source/sococo.coffee"

    coffeelint:
      client: ["Gruntfile.coffee", "source/**/*.coffee"]
      options:
        indentation:
          value: 2
          level: 'error'
        no_empty_param_list:
          level: 'ignore'
        no_implicit_braces:
          level: 'ignore'
        no_implicit_parens:
          level: 'ignore'
        max_line_length:
          level: 'ignore'

  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-coffeelint"
  
  # Default task.
  grunt.registerTask "default", ["coffee", "coffeelint"]

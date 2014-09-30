#global module:false
module.exports = (grunt) ->

  # Project configuration.
  grunt.initConfig
    watch:
      files: ["source/**/*.coffee"]
      tasks: ["coffee", "coffeelint"]

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

    # Release/Deploy tasks
    bump:
      options:
        files: ['package.json'],
        commit: true,
        commitMessage: 'chore(deploy): release v%VERSION%',
        commitFiles: ['package.json', 'CHANGELOG.md'],
        createTag: true,
        tagName: 'v%VERSION%',
        tagMessage: 'Version %VERSION%',
        push: false,
        gitDescribeOptions: '--tags --always --abbrev=1 --dirty=-d'
    changelog: {}
    'npm-contributors':
      options:
        commitMessage: 'chore(attribution): update contributors'

  grunt.loadNpmTasks "grunt-bump"
  grunt.loadNpmTasks "grunt-conventional-changelog"
  grunt.loadNpmTasks "grunt-npm"
  grunt.loadNpmTasks "grunt-contrib-watch"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-coffeelint"

  # Default task.
  grunt.registerTask "default", ["coffee", "coffeelint"]

  grunt.registerTask "publish", ["npm-publish"]

  grunt.registerTask "release", "Build, bump and tag a new release.", (type="patch") ->
    grunt.task.run [
      "npm-contributors",
      "bump:" + type + ":bump-only",
      "changelog",
      "bump-commit"
    ]

#
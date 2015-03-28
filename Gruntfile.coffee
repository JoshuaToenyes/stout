module.exports = (grunt) ->

  config =

    pkg: (grunt.file.readJSON('package.json'))

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['src/**/*.coffee']

    coffee:
      options:
        sourceMap: true
      app:
        expand: true
        flatten: false
        cwd: 'src'
        src: ['./**/*.coffee']
        dest: 'dist'
        ext: '.js'
      test:
        expand: true
        flatten: false
        cwd: 'test'
        src: ['./**/*.coffee']
        dest: 'test'
        ext: '.js'

    browserify:
      test:
        files:
          'test/integration/client/basic-app.js': ['test/integration/client/basic-app.js']

    watch:
      compile:
        files: ['src/**/*.coffee', 'test/**/*.coffee']
        tasks: ['compile']
        configFiles:
          files: ['Gruntfile.coffee']
          options:
            reload: true
      test:
        files: ['src/**/*.coffee', 'test/**/*.coffee']
        tasks: ['test']
        configFiles:
          files: ['Gruntfile.coffee']
          options:
            reload: true

    clean:
      all: [
        'dist',
        'src/**/*.js'
        'src/**/*.map'
        'test/**/*.js'
        'test/**/*.map'
      ]


    mochaTest:
      unit:
        src: ['test/unit/**/*.js']
      integration:
        src: ['test/integration/**/*.js']


  grunt.initConfig(config)
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-mocha-test'

  grunt.registerTask 'compile', [
    'coffeelint'
    'clean'
    'coffee'
    ]

  grunt.registerTask 'test', [
    'compile'
    'mochaTest'
  ]

  grunt.registerTask 'test:unit', [
    'compile'
    'mochaTest:unit'
  ]

  grunt.registerTask 'test:integration', [
    'compile'
    'mochaTest:integration'
  ]

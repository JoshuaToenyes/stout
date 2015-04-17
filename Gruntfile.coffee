#modRewrite = require('connect-modrewrite');

module.exports = (grunt) ->

  config =

    pkg: grunt.file.readJSON('package.json')

    bump:
      options:
        prereleaseName: 'alpha'
        pushTo: 'origin'

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['src/**/*.coffee']

    coffee:
      options:
        sourceMap: false
      app:
        expand: true
        flatten: false
        cwd: 'src'
        src: ['./**/*.coffee']
        dest: ''
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
          'test/integration/client/app-startup.js': ['test/integration/client/app-startup.js']

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
        'client',
        'common',
        'server',
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


    connect:
      server:
        options:
          port: 9999
          base: 'test/integration/client'
          middleware: (connect, options, middlewares) ->
            middlewares.unshift(modRewrite(['!\\.html|\\.js|\\.svg|\\.css|\\.png$ /index.html [L]']))
            return middlewares

    open:
      test:
        path: 'http://localhost:9999/test/integration/client'
        app: 'Safari'


  grunt.initConfig(config)

  for pkg of config.pkg.devDependencies
    if /grunt\-/.test pkg
      grunt.loadNpmTasks pkg

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

module.exports = (grunt) ->
  
  config =

    pkg: (grunt.file.readJSON('package.json'))

    coffeelint:
      options:
        configFile: 'coffeelint.json'
      app: ['src/**/*.coffee']

    coffee:
      app:
        expand: true,
        flatten: false,
        cwd: 'src',
        src: ['app/**/*.coffee'],
        dest: 'dist',
        ext: '.js'
      cli:
        files: 'dist/critiqa': 'src/cli.coffee'
      test:
        expand: true,
        flatten: false,
        cwd: 'test',
        src: ['./**/*.coffee'],
        dest: 'test',
        ext: '.js'

    file_append:
      default_options:
        files:
          'dist/critiqa':
            prepend: '#! /usr/bin/node\n'
            input: 'dist/critiqa'

    copy:
      dist:
        files: [
          {expand: true, src: ['package.json', 'config/*', 'mongo.js', '.npmrc'], dest: 'dist/'}
        ]

    chmod:
      options:
        mode: '770'
      critiqa:
        src: 'dist/critiqa'

    watch:
      files: ['src/**/*.coffee', 'test/**/*.coffee'],
      tasks: ['compile']
      configFiles:
        files: ['Gruntfile.coffee']
        options:
          reload: true

    clean:
      all: ['dist/*', 'test/**/*.js']
      cli: ['dist/critiqa']

    replace:
      version: 
        src: ['dist/critiqa', 'dist/app/app.js'],
        overwrite: true,
        replacements: [{
          from: "*|VERSION|*",
          to: "<%= pkg.version %>"
        }]
    
    mocha_phantomjs:
      all: ['test/**/*.html']

    mochaTest:
      test:
        src: ['test/**/*.js']

    # ### groc
    # Generates the documentation files and outputs them to the `doc/`
    # directory.
    groc:
      all: [
        'src/**/*.coffee'
        'test/**/*.coffee'
        'Gruntfile.coffee'
        'README.md']
      options:
        out: 'doc/'
  
  
  grunt.initConfig(config)
  grunt.loadNpmTasks('grunt-coffeelint')
  grunt.loadNpmTasks('grunt-groc')
  grunt.loadNpmTasks('grunt-contrib-copy')
  grunt.loadNpmTasks('grunt-contrib-coffee')
  grunt.loadNpmTasks('grunt-contrib-watch')
  grunt.loadNpmTasks('grunt-contrib-clean')
  grunt.loadNpmTasks('grunt-mocha-phantomjs')
  grunt.loadNpmTasks('grunt-mocha-test')
  grunt.loadNpmTasks('grunt-file-append')
  grunt.loadNpmTasks('grunt-chmod')
  grunt.loadNpmTasks('grunt-text-replace')

  grunt.registerTask('vagrant', ['copy'])

  grunt.registerTask('compile', [
    'coffeelint', 
    'clean:cli', 
    'coffee', 
    'file_append',
    'replace:version',
    'chmod']);

  grunt.registerTask('test', ['compile', 'mochaTest']);

  # ### doc
  # Generates project documentation.
  grunt.registerTask('doc', ['groc'])

module.exports = (g) ->
  g.initConfig
    spec:
      unit:
        options:
          helpers: 'spec/helpers/**/*.{js,coffee}'
          specs: 'spec/**/*.{js,coffee}'
      e2e:
        options:
          helpers: 'spec/helpers/**/*.{js,coffee}'
          specs: 'spec-e2e/**/*.{js,coffee}'

  g.loadNpmTasks 'grunt-jasmine-bundle'
  g.registerTask 'default', ['spec:unit', 'spec:e2e']

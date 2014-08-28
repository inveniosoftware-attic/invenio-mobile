module.exports = (grunt) ->

	grunt.initConfig {
		pkg: grunt.file.readJSON('package.json')
		less: {
			build: {
				files: [
					{
						expand: true
						cwd: 'www/less/'
						src: ['**/*.less']
						dest: 'www/cssbin/'
						ext: '.css'
					}
				]
			}
		}
		coffee: {
			build: {
				files: [
					{
						expand: true
						cwd: 'www/coffee/'
						src: ['**/*.coffee']
						dest: 'www/jsbin/'
						ext: '.js'
					}
				]
			}
		}
	}

	grunt.loadNpmTasks('grunt-contrib-less')
	grunt.loadNpmTasks('grunt-contrib-coffee')

	grunt.registerTask('default', ['less', 'coffee'])

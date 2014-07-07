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
	}

	grunt.loadNpmTasks('grunt-contrib-less')

	grunt.registerTask('default', ['less'])

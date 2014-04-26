'use strict';

module.exports = function(grunt) {
    // Project configuration.
    var gruntConf = {
        watch: {
            coffee: {
                files: ['./coffee/*.coffee'],
                tasks: ['coffee']
            },
        },
        coffee: {
            default: {
                expand: true,
                cwd: 'coffee',
                src: ['*.coffee'],
                dest: 'dist',
                ext: '.js',
                options: {
                    bare: true
                }
            }
        },
        taskDefault: ['coffee']
    };

    grunt.initConfig(gruntConf);

    // These plugins provide necessary tasks.
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.registerTask('default', gruntConf.taskDefault);
};
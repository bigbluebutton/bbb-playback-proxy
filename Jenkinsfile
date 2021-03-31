node {
    def app
    def scmVars = checkout scm

    stage('Clone repository') {
        checkout scm
    }

    stage('Build images') {
        /* This builds the actual image; synonymous to
         * docker build on the command line */

        gitRepo = sh(returnStdout: true, script: 'echo -n "$(basename $(dirname '+scmVars.GIT_URL+'))/$(basename '+scmVars.GIT_URL+' .git)":'+dockerfile)
        // gitRepo = sh(returnStdout: true, script: 'echo -n "$(basename $(dirname '+scmVars.GIT_URL+'))/'+dockerfile+'"')
        app = docker.build("${gitRepo}", "--target bbb-playback-proxy -f dockerfiles/${dockerfile} .")
    }

    stage('Test image') {
        /* Ideally, we would run a test framework against our image.
         * For this example, we're using a Volkswagen-type approach ;-) */

        app.inside {
            sh 'echo "Tests passed"'
        }
    }

    stage('Push image') {
        /* Finally, we'll push the image with two tags:
         * First, the incremental build number from Jenkins
         * Second, the 'latest' tag.
         * Pushing multiple tags is cheap, as all the layers are reused. */

        gitBranch = sh(returnStdout: true, script: 'echo -n "$(basename '+scmVars.GIT_BRANCH+')"')
        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-id') {
            app.push("${dockerfile}-${env.BUILD_NUMBER}")
            app.push("${dockerfile}")
        }
    }
}

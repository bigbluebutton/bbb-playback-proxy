node {
    def app
    def scmVars = checkout scm

    stage('Clone repository') {
        checkout scm
    }

    stage('Build images') {
        gitRepo = sh(returnStdout: true, script: 'echo -n "$(basename $(dirname '+scmVars.GIT_URL+'))/$(basename '+scmVars.GIT_URL+' .git)":'+dockerfile)
        app = docker.build("${gitRepo}", "--pull --target bbb-playback-proxy -f dockerfiles/${dockerfile} .")
    }

    stage('Push image') {
        gitBranch = sh(returnStdout: true, script: 'echo -n "$(basename '+scmVars.GIT_BRANCH+')"')
        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-id') {
            app.push("${dockerfile}-${env.BUILD_NUMBER}")
            app.push("${dockerfile}")
        }
    }
}

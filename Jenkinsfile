node {
    def app
    def scmVars

    stage('Clone repository') {
        scmVars = checkout scm
    }

    stage('Build images') {
        gitRepo = sh(returnStdout: true, script: 'echo -n "$(basename $(dirname '+scmVars.GIT_URL+'))/$(basename '+scmVars.GIT_URL+' .git)":'+dockerfile+'-'+baseimagetag)
        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-id') {
            app = docker.build("${gitRepo}", "--pull --build-arg TAG=${baseimagetag} --build-arg NGINX_VERSION=${nginxversion} --target bbb-playback-proxy -f dockerfiles/${dockerfile} .")
        }
    }

    stage('Push image') {
        gitBranch = sh(returnStdout: true, script: 'echo -n "$(basename '+scmVars.GIT_BRANCH+')"')
        docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-id') {
            app.push("${dockerfile}-${baseimagetag}-${env.BUILD_NUMBER}")
            app.push("${dockerfile}-${baseimagetag}")
        }
    }
}

node {
  def appName = 'app-go'
  def frontendSvcName = "app-frontend"

  final scmVars = checkout(scm)
  echo "scmVars: ${scmVars}"

  def imageTag = "krol/${appName}:${env.BRANCH_NAME}-${scmVars.GIT_COMMIT}"

  stage 'Check docker version'
  sh("docker version")

  stage 'Build image'
  def customImage = docker.build("${imageTag}")

  stage 'Run Go tests'
  customImage.inside {
      sh 'go test'
  }

  stage 'Push image to registry'

  withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId:'docker-krol', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD']]) {
    sh "docker login -u=$USERNAME -p=$PASSWORD"
    sh("docker push ${imageTag}")
  }

  stage "Deploy Application"
  switch (env.BRANCH_NAME) {
    // Roll out to canary environment
    case "canary":
        // Change deployed image in canary to the one we just built
        sh("sed -i.bak 's#krol/app-go:dev#${imageTag}#' ./k8s/canary/*.yaml")
        sh("kubectl --namespace=production apply -f k8s/services/")
        sh("kubectl --namespace=production apply -f k8s/canary/")
        sh("echo http://`kubectl --namespace=production get service/${frontendSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${frontendSvcName}")
        break

    // Roll out to production
    case "master":
        // Change deployed image in canary to the one we just built
        sh("sed -i.bak 's#krol/app-go:dev#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=production apply -f k8s/services/")
        sh("kubectl --namespace=production apply -f k8s/production/")
        sh("echo http://`kubectl --namespace=production get service/${frontendSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${frontendSvcName}")
        break

    // Roll out a dev environment
    default:
        // Create namespace if it doesn't exist
        sh("sed -i.bak 's#krol/app-go:dev#${imageTag}#' ./k8s/dev/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
        sh("echo http://`kubectl --namespace=dev get service/${frontendSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${frontendSvcName}")
        break
  }
}
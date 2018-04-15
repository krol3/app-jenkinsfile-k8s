node {
  def project = 'REPLACE_WITH_YOUR_PROJECT_ID'
  def appName = 'app-go'
  def feSvcName = "${appName}-frontend"

  final scmVars = checkout(scm)
  echo "scmVars: ${scmVars}"
  echo "scmVars.GIT_COMMIT: ${scmVars.GIT_COMMIT}"
  echo "scmVars.GIT_BRANCH: ${scmVars.GIT_BRANCH}"
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
  }

  withDockerRegistry([ credentialsId: "docker-krol", url: "https://index.docker.io/v2/" ]) {
      sh 'echo uname=$USERNAME pwd=$PASSWORD'
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
        sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out to production
    case "master":
        // Change deployed image in canary to the one we just built
        sh("sed -i.bak 's#krol/app-go:dev#${imageTag}#' ./k8s/production/*.yaml")
        sh("kubectl --namespace=production apply -f k8s/services/")
        sh("kubectl --namespace=production apply -f k8s/production/")
        sh("echo http://`kubectl --namespace=production get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
        break

    // Roll out a dev environment
    default:
        // Create namespace if it doesn't exist
        sh("sed -i.bak 's#krol/app-go:dev#${imageTag}#' ./k8s/dev/*.yaml")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/services/")
        sh("kubectl --namespace=${env.BRANCH_NAME} apply -f k8s/dev/")
        echo 'To access your environment run `kubectl proxy`'
        echo "Then access your service via http://localhost:8001/api/v1/proxy/namespaces/${env.BRANCH_NAME}/services/${feSvcName}:80/"
  }
}
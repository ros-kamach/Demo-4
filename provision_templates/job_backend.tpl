<?xml version='1.1' encoding='UTF-8'?>
<project>
  <actions/>
  <description>Job eSchool backend</description>
  <keepDependencies>false</keepDependencies>
  <properties>
    <hudson.plugins.disk__usage.DiskUsageProperty plugin="disk-usage@0.28"/>
    <com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty plugin="gitlab-plugin@1.5.12">
      <gitLabConnection></gitLabConnection>
    </com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty>
    <hudson.plugins.throttleconcurrents.ThrottleJobProperty plugin="throttle-concurrents@2.0.1">
      <maxConcurrentPerNode>0</maxConcurrentPerNode>
      <maxConcurrentTotal>0</maxConcurrentTotal>
      <categories class="java.util.concurrent.CopyOnWriteArrayList"/>
      <throttleEnabled>false</throttleEnabled>
      <throttleOption>project</throttleOption>
      <limitOneJobWithMatchingParams>false</limitOneJobWithMatchingParams>
      <paramsToUseForLimit></paramsToUseForLimit>
    </hudson.plugins.throttleconcurrents.ThrottleJobProperty>
  </properties>
  <scm class="hudson.plugins.git.GitSCM" plugin="git@3.10.0">
    <configVersion>2</configVersion>
    <userRemoteConfigs>
      <hudson.plugins.git.UserRemoteConfig>
        <url>https://github.com/IF-090Java/eSchool.git</url>
      </hudson.plugins.git.UserRemoteConfig>
    </userRemoteConfigs>
    <branches>
      <hudson.plugins.git.BranchSpec>
        <name>*/master</name>
      </hudson.plugins.git.BranchSpec>
    </branches>
    <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
    <submoduleCfg class="list"/>
    <extensions/>
  </scm>
  <canRoam>true</canRoam>
  <disabled>false</disabled>
  <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
  <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
  <triggers/>
  <concurrentBuild>false</concurrentBuild>
  <builders>
    <hudson.plugins.sonar.SonarRunnerBuilder plugin="sonar@2.8.1">
      <project></project>
      <properties>sonar.projectKey=my:backend
sonar.projectName=My backend
sonar.projectVersion=1.0
sonar.sources=.
sonar.exclusions=**/*.java</properties>
      <javaOpts></javaOpts>
      <additionalArguments></additionalArguments>
      <jdk>(Inherit From Job)</jdk>
      <task></task>
    </hudson.plugins.sonar.SonarRunnerBuilder>
    <hudson.tasks.Maven>
      <targets>clean package</targets>
      <mavenName>Maven_name</mavenName>
      <usePrivateRepository>false</usePrivateRepository>
      <settings class="jenkins.mvn.DefaultSettingsProvider"/>
      <globalSettings class="jenkins.mvn.DefaultGlobalSettingsProvider"/>
      <injectBuildVariables>false</injectBuildVariables>
    </hudson.tasks.Maven>
    <hudson.tasks.Shell>
      <command>jar_file=&quot;/tmp/templates/backend/eschool.jar&quot;
if [ -f &quot;$jar_file&quot; ];
then
echo &quot;$jar_file exist, i&apos;ll delete it and copy builded&quot;
sudo rm &quot;$jar_file&quot;
else
echo &quot;$jar_file not exist, i&apos;ll copy builded&quot;
fi
sudo cp ./target/eschool.jar /tmp/templates/backend/</command>
    </hudson.tasks.Shell>
    <org.jenkinsci.plugins.ansible.AnsiblePlaybookBuilder plugin="ansible@1.0">
      <playbook>/tmp/templates/ansible_docker/backend.yml</playbook>
      <inventory class="org.jenkinsci.plugins.ansible.InventoryDoNotSpecify"/>
      <limit></limit>
      <tags></tags>
      <skippedTags></skippedTags>
      <startAtTask></startAtTask>
      <credentialsId></credentialsId>
      <vaultCredentialsId></vaultCredentialsId>
      <become>false</become>
      <becomeUser></becomeUser>
      <sudo>false</sudo>
      <sudoUser></sudoUser>
      <forks>5</forks>
      <unbufferedOutput>true</unbufferedOutput>
      <colorizedOutput>false</colorizedOutput>
      <disableHostKeyChecking>false</disableHostKeyChecking>
      <additionalParameters></additionalParameters>
      <copyCredentialsInWorkspace>false</copyCredentialsInWorkspace>
    </org.jenkinsci.plugins.ansible.AnsiblePlaybookBuilder>
    <jenkins.plugins.publish__over__ssh.BapSshBuilderPlugin plugin="publish-over-ssh@1.20.1">
      <delegate>
        <consolePrefix>SSH: </consolePrefix>
        <delegate plugin="publish-over@0.22">
          <publishers>
            <jenkins.plugins.publish__over__ssh.BapSshPublisher plugin="publish-over-ssh@1.20.1">
              <configName>localhost</configName>
              <verbose>false</verbose>
              <transfers>
                <jenkins.plugins.publish__over__ssh.BapSshTransfer>
                  <remoteDirectory></remoteDirectory>
                  <sourceFiles></sourceFiles>
                  <excludes></excludes>
                  <removePrefix></removePrefix>
                  <remoteDirectorySDF>false</remoteDirectorySDF>
                  <flatten>false</flatten>
                  <cleanRemote>false</cleanRemote>
                  <noDefaultExcludes>false</noDefaultExcludes>
                  <makeEmptyDirs>false</makeEmptyDirs>
                  <patternSeparator>[, ]+</patternSeparator>
                  <execCommand>gcloud auth activate-service-account --key-file /tmp/ansible/.ssh/${gcp_credential_json}
gcloud beta container clusters get-credentials ${kubernetes_cluster} --region ${region} --project ${gcp_project_id}     
kubectl create secret docker-registry gcr-json-key --docker-server=us.gcr.io --docker-username=_json_key --docker-password="$(cat /tmp/ansible/.ssh/${gcp_credential_json})" --docker-email=ros.kamach@gmail.com
kubectl patch serviceaccount default -p '{"imagePullSecrets": [{"name": "gcr-json-key"}]}'
kubectl create secret generic cloudsql-instance-credentials --from-file=credentials.json=/tmp/ansible/.ssh/${gcp_credential_json}
kubectl create secret generic cloudsql-db-credentials --from-literal=username=${db_user} --from-literal=password=${db_pass}
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)
###UNCOMMENT NEXT 5 lines IF WANT TO USE NGINX-INGRESS ####
#kubectl apply -f /tmp/templates/kubernetes/ingress-nginx/mandatory.yaml
#kubectl apply -f /tmp/templates/kubernetes/ingress-nginx/cloud-generic.yaml
#kubectl apply -f /tmp/templates/kubernetes/deploy_backend.yaml
#kubectl apply -f /tmp/templates/kubernetes/backend_service.yaml
#kubectl apply -f /tmp/templates/kubernetes/ingress-nginx/ingress_backend.yaml
###UNCOMMENT NEXT 4 lines IF WANT TO USE AMBASSADOR ####
#kubectl apply -f /tmp/templates/kubernetes/ambassador/rbac.yaml
#kubectl apply -f /tmp/templates/kubernetes/ambassador/amb_lb.yaml
#kubectl apply -f /tmp/templates/kubernetes/deploy_backend.yaml
#kubectl apply -f /tmp/templates/kubernetes/ambassador/amb_backend.yaml</execCommand>
                  <execTimeout>120000</execTimeout>
                  <usePty>false</usePty>
                  <useAgentForwarding>false</useAgentForwarding>
                </jenkins.plugins.publish__over__ssh.BapSshTransfer>
              </transfers>
              <useWorkspaceInPromotion>false</useWorkspaceInPromotion>
              <usePromotionTimestamp>false</usePromotionTimestamp>
            </jenkins.plugins.publish__over__ssh.BapSshPublisher>
          </publishers>
          <continueOnError>false</continueOnError>
          <failOnError>false</failOnError>
          <alwaysPublishFromMaster>false</alwaysPublishFromMaster>
          <hostConfigurationAccess class="jenkins.plugins.publish_over_ssh.BapSshPublisherPlugin" reference="../.."/>
        </delegate>
      </delegate>
    </jenkins.plugins.publish__over__ssh.BapSshBuilderPlugin>
  </builders>
  <publishers>
    <hudson.plugins.ws__cleanup.WsCleanup plugin="ws-cleanup@0.37">
      <patterns class="empty-list"/>
      <deleteDirs>false</deleteDirs>
      <skipWhenFailed>false</skipWhenFailed>
      <cleanWhenSuccess>true</cleanWhenSuccess>
      <cleanWhenUnstable>true</cleanWhenUnstable>
      <cleanWhenFailure>true</cleanWhenFailure>
      <cleanWhenNotBuilt>true</cleanWhenNotBuilt>
      <cleanWhenAborted>true</cleanWhenAborted>
      <notFailBuild>false</notFailBuild>
      <cleanupMatrixParent>false</cleanupMatrixParent>
      <externalDelete></externalDelete>
      <disableDeferredWipeout>false</disableDeferredWipeout>
    </hudson.plugins.ws__cleanup.WsCleanup>
  </publishers>
  <buildWrappers/>
</project>
pipeline {

  agent { label 'azure' }

  parameters{
      string(defaultValue: 'Project name', name: 'Project', description: 'Create a project to spin up an azure IAAS instance', trim: true)
      string(defaultValue: 'https://github.com/woodez-terraform/python-docs-hello-django.git', name: 'giturl', description: 'git url for app code')
      string(defaultValue: 'master', name: 'branch', description: 'git branch')
      string(defaultValue: 'eastus2', name: 'Location', description: 'azure region')
      choice(choices: ['Free'], name: 'tier', description: 'app service plan tier')
      choice(choices: ['F1'], name: 'size', description: 'app service plan size')
      choice(choices: ['Build', 'Teardown', 'Show'], description: 'Pick a action that you want to perform on your project', name: 'Action')
  }

  stages {

    stage('Putting on Magic Hat') {
      steps {
          checkout scm
      }  
    }

    stage('Pulling App Service in Azure out of Hat') {
        steps {
            script {
                if (params.Action == "Build"){
                    sh """
                       terraform get -update
                       terraform init -upgrade -backend-config='conn_str=postgres://tf_user:jandrew28@192.168.2.213/terraform_backend?sslmode=disable'
                       terraform workspace select default
                       terraform workspace list > current-workspaces
                       [[ `grep ${params.Project} current-workspaces` ]] || terraform workspace new ${params.Project}
                       terraform workspace list
                       terraform workspace select ${params.Project}
                       terraform plan -var=\"project=${params.Project}\" -var=\"giturl=${params.giturl}\" -var=\"branch=${params.branch}\" -var=\"tier=${params.tier}\" -var=\"size=${params.size}\" -out myplan                    
                       terraform apply -input=false myplan
                       rm -f myplan
                       terraform output
                    """    
                }
                else {
                    sh """
                       terraform workspace select ${params.Project}
                       terraform destroy -var=\"project=${params.Project}\" -var=\"giturl=${params.giturl}\" -var=\"branch=${params.branch}\" -var=\"tier=${params.tier}\" -var=\"size=${params.size}\" -auto-approve
                       terraform workspace select default
                       terraform workspace delete ${params.Project}  
                    """
                }
            }
        }
    }

    stage('Deploying app to app service') {
        steps {
            script {
                if (params.Action == "Build"){
                    build job: 'app-service-deploy', parameters: [
                    string(name: 'Location', value: "${params.Location}"),
                    string(name: 'Resourcegroup', value: "${params.Project}-app-rg"),
                    string(name: 'Appserviceplan', value: "${params.Project}-appserviceplan"),
                    string(name: 'Appservice', value: "${params.Project}-app-service"),
                    string(name: 'appurl', value: "${params.giturl}"),
                    string(name: 'tier', value: "Free"),
                    string(name: 'size', value: "F1")   
                    ]
                }
                else {
                    sh """
                       echo NOT_DOING_CODE_DEPLOY_ON_A_TEARDOWN 
                    """
                }
            }
        }
    }
    stage('Magic Show is over..BOOOOM'){
        steps {
            echo 'Thanks for Attending Magic show..'
        }
    } 
    
  } 
}
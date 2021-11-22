pipeline {

  agent { label 'azure' }

  parameters{
      string(defaultValue: 'Project name', name: 'Project', description: 'Create a project to spin up an azure IAAS instance', trim: true)
      string(defaultValue: 'Git url', name: 'giturl', description: 'git url for app code')
      string(defaultValue: 'master', name: 'branch', description: 'git branch')
      string(defaultValue: 'pick tier', name: 'tier', description: 'app service plan tier')
      string(defaultValue: 'pick size', name: 'size', description: 'app service plan size')
      choice(choices: ['Build', 'Teardown', 'Show'], description: 'Pick a action that you want to perform on your project', name: 'Action')
  }

  stages {

    stage('Checkout') {
      steps {
          checkout scm
      }  
    }

    stage('apply terraform') {
        steps {
            script {
                if (params.Action == "Build"){
                    sh """
                       terraform get -update
                       terraform init -upgrade -backend-config='conn_str=postgres://tf_user:jandrew28@192.168.2.213/terraform_backend?sslmode=disable'
                       terraform workspace select default
                       terraform workspace list > current-workspaces
                       [[ $(grep twood current-workspaces) ]] && terraform workspace delete -force ${params.Project}
                       terraform workspace new ${params.Project}
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

  } 
}
terraform {
  backend "pg" {
      conn_str="postgres://tf_user:jandrew28@192.168.2.213/terraform_backend?sslmode=disable"
  }  
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "${var.project}-app-rg"
  location = "${var.location}"
}

resource "azurerm_app_service_plan" "example" {
  name                = "${var.project}-appserviceplan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    tier = "Free"
    size = "F1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "${var.project}-app-service"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    python_version = "v3.8"
    scm_type   = "LocalGit"
  }
 
  source_control {
    repo_url           = "${var.giturl}"
    branch             = "master"
    manual_integration = true
    use_mercurial      = false
  }

}
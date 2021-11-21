terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
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
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "${var.tier}"
    size = "${var.size}"
  }
}

resource "azurerm_app_service" "example" {
  name                = "${var.project}-app-service"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

#  source_control {
#    repo_url           = "${var.giturl}"
#    branch             = "${var.branch}"
#  }

  lifecycle {
    ignore_changes = [site_config.0.scm_type]
  
  }
}

resource "azurerm_app_service_source_control" "example" {
  app_service_id        = "${azurerm_app_service.example.id}"
  repo_url              = "${var.giturl}"
  is_manual_integration = true
  branch                = "${var.branch}"
}
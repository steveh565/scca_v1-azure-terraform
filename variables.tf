# REST API Setting
variable rest_do_uri { default	= "/mgmt/shared/declarative-onboarding" }
variable rest_as3_uri { default = "/mgmt/shared/appsvcs/declare" }
variable rest_ts_uri { default = "/mgmt/shared/telemetry/declare" }
variable rest_do_method { default = "POST" }
variable rest_as3_method { default = "POST" }
variable rest_f5vm01_do_file {default = "f5vm01_do_data.json" }
variable rest_f5vm02_do_file {default = "f5vm02_do_data.json" }
variable rest_fwvm01_do_file {default = "fwvm01_do_data.json" }
variable rest_fwvm02_do_file {default = "fwvm02_do_data.json" }
variable rest_fwvm_as3_file {default = "fwvm_as3_data.json" }
variable rest_vm_ts_file { default = "vm_ts_data.json" }

# Azure Environment
variable "SP" {
        type = "map"
        default = {
                subscription_id = "NULL"
                client_id       = "NULL"
                client_secret   = "NULL"
                tenant_id       = "NULL"
        }
}
variable prefix	{ default = "myRg" }
variable uname	{ default = "azops" }
variable upassword	{ default = "Password" }
variable location	{ default = "canadacentral" }	 
variable region		{ default = "Canada Central" }

# NETWORK
variable cidr	{ default = "10.90.0.0/16" }
variable "subnets" {
	type = "map"
	default = {
		"subnet1" = "10.90.1.0/24"
		"subnet2" = "10.90.2.0/24"
		"subnet3" = "10.90.3.0/24"
                "subnet4" = "10.90.4.0/24"
                "subnet5" = "10.90.5.0/24"
                "subnet6" = "10.90.6.0/24"
                "subnet7" = "10.90.7.0/24"
                "subnet8" = "10.90.8.0/24"
	}
}
variable app-cidr   { default = "10.80.0.0/16" }
variable app2-cidr   { default = "10.70.0.0/16" }
variable "app-subnets" {
        type = "map"
        default = {
                "subnet1" = "10.80.1.0/24"
                "subnet2" = "10.80.2.0/24"
                "subnet3" = "10.80.3.0/24"
        }
}

variable "app2-subnets" {
        type = "map"
        default = {
                "subnet1" = "10.70.1.0/24"
                "subnet2" = "10.70.2.0/24"
                "subnet3" = "10.70.3.0/24"
        }
}

#External Big-IPs
variable f5vm01mgmt	{ default = "10.90.1.4" }
variable f5vm01ext	{ default = "10.90.2.4" }
variable f5vm01ext_sec  { default = "10.90.2.14" }
variable f5vm01ToSC	{ default = "10.90.3.4" }
variable f5vm01ToSC_sec	{ default = "10.90.3.14" }
variable f5vm01FrSC	{ default = "10.90.4.4" }
variable f5vm01FrSC_sec	{ default = "10.90.4.14" }
variable f5vm01internal { default = "10.90.5.4" }
variable f5vm01internal_sec { default = "10.90.5.14" }

variable f5vm02mgmt	{ default = "10.90.1.5" }
variable f5vm02ext	{ default = "10.90.2.5" }
variable f5vm02ext_sec  { default = "10.90.2.15" }
variable f5vm02ToSC	{ default = "10.90.3.5" }
variable f5vm02ToSC_sec	{ default = "10.90.3.15" }
variable f5vm02FrSC	{ default = "10.90.4.5" }
variable f5vm02FrSC_sec	{ default = "10.90.4.15" }
variable f5vm02internal { default = "10.90.5.5" }
variable f5vm02internal_sec { default = "10.90.5.15" }

#Internal Big-IPs
variable f5vm03mgmt	{ default = "10.90.1.6" }
variable f5vm03int	{ default = "10.90.5.6" }
variable f5vm03int_sec  { default = "10.90.5.16" }
variable f5vm03int2sc	{ default = "10.90.6.6" }
variable f5vm03int2sc_sec	{ default = "10.90.6.16" }
variable f5vm03sc2int	{ default = "10.90.7.6" }
variable f5vm03sc2int_sec	{ default = "10.90.7.16" }

variable f5vm04mgmt	{ default = "10.90.1.7" }
variable f5vm04int	{ default = "10.90.5.7" }
variable f5vm04int_sec  { default = "10.90.5.17" }
variable f5vm04int2sc	{ default = "10.90.6.7" }
variable f5vm04int2sc_sec	{ default = "10.90.6.17" }
variable f5vm04sc2int	{ default = "10.90.7.7" }
variable f5vm04sc2int_sec	{ default = "10.90.7.17" }

#External Firewalls
variable fwlb_feip      { default = "10.90.3.200"}
variable fwvm01mgmt     { default = "10.90.1.8" }
variable fwvm01ToSC   { default = "10.90.3.8" }
variable fwvm01ToSC_sec   { default = "10.90.3.18" }
variable fwvm01FrSC   { default = "10.90.4.8" }
variable fwvm01FrSC_sec   { default = "10.90.4.18" }

variable fwvm02mgmt     { default = "10.90.1.9" }
variable fwvm02ToSC   { default = "10.90.3.9" }
variable fwvm02ToSC_sec   { default = "10.90.3.19" }
variable fwvm02FrSC   { default = "10.90.4.9" }
variable fwvm02FrSC_sec   { default = "10.90.4.19" }

#Internal Firewalls
variable fwvm03mgmt     { default = "10.90.1.20" }
variable fwvm03int2sc   { default = "10.90.3.20" }
variable fwvm03int2sc_sec   { default = "10.90.3.20" }
variable fwvm03sc2int   { default = "10.90.4.20" }
variable fwvm03sc2int_sec   { default = "10.90.4.20" }

variable fwvm04mgmt     { default = "10.90.1.21" }
variable fwvm04int2sc   { default = "10.90.3.21" }
variable fwvm04int2sc_sec   { default = "10.90.3.21" }
variable fwvm04sc2int   { default = "10.90.4.21" }
variable fwvm04sc2int_sec   { default = "10.90.4.21" }

#App1 backend container node
variable backend01ext   { default = "10.80.1.101" }

# BIGIP Image
variable instance_type	{ default = "Standard_DS4_v2" }
variable image_name	{ default = "f5-big-all-2slot-byol" }
variable product	{ default = "f5-big-ip-byol" }
variable bigip_version	{ default = "latest" }

# BIGIP Setup
## These licenses have been tested with F5-BIG-LTM-VE-1G-V16 base SKU 
variable license1             { default = "NULL" }
variable license2             { default = "NULL" }
variable license3             { default = "NULL" }
variable license4             { default = "NULL" }
variable host1_name           { default = "f5vm01" }
variable host2_name           { default = "f5vm02" }
variable fwhost1_name         { default = "fwvm01" }
variable fwhost2_name         { default = "fwvm02" }
variable dns_server           { default = "8.8.8.8" }
variable ntp_server           { default = "0.us.pool.ntp.org" }
variable timezone             { default = "UTC" }
## Please check and update the latest DO URL from https://github.com/F5Networks/f5-declarative-onboarding/releases
variable DO_onboard_URL	      { default = "https://github.com/garyluf5/f5tools/raw/master/f5-declarative-onboarding-1.7.0-3.noarch.rpm" }
## Please check and update the latest AS3 URL from https://github.com/F5Networks/f5-appsvcs-extension/releases/latest 
variable AS3_URL	      { default = "https://github.com/garyluf5/f5tools/raw/master/f5-appsvcs-3.14.0-4.noarch.rpm" }
## Please check and update the latest Telemetry Streaming from https://github.com/F5Networks/f5-telemetry-streaming/tree/master/dist
variable TS_URL	      	      { default = "https://github.com/garyluf5/f5tools/raw/master/f5-telemetry-1.5.0-1.noarch.rpm" }
## Please check and update the latest Cloud Failover from https://github.com/f5devcentral/f5-cloud-failover-extension
variable CF_URL	      	      { default = "https://github.com/f5devcentral/f5-cloud-failover-extension/releases/download/v0.9.1/f5-cloud-failover-0.9.1-1.noarch.rpm" }
variable libs_dir	      { default = "/config/cloud/azure/node_modules" }
variable onboard_log	      { default = "/var/log/startup-script.log" }

# TAGS
variable purpose        { default = "public"       }
variable environment    { default = "f5env"        }  #ex. dev/staging/prod
variable owner          { default = "f5owner"      }
variable group          { default = "f5group"      }
variable costcenter     { default = "f5costcenter" }
variable application    { default = "f5app"        }

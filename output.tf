output "FoggyKitchenJenkinsURL" {
   value = [join("", ["http://", data.oci_core_vnic.FoggyKitchenJenkins_VNIC1.public_ip_address, ":8080"])]
}


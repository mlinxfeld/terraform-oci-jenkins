resource "oci_core_instance" "FoggyKitchenJenkins" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name")
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  display_name = "FoggyKitchenJenkins"
  shape = var.Shapes[0]
  subnet_id = oci_core_subnet.FoggyKitchenWebSubnet.id
  source_details {
    source_type = "image"
    source_id   = lookup(data.oci_core_images.OSImageLocal.images[0], "id")
  }
  metadata = {
    ssh_authorized_keys = tls_private_key.public_private_key_pair.public_key_openssh
  }
  create_vnic_details {
     subnet_id = oci_core_subnet.FoggyKitchenWebSubnet.id
     assign_public_ip = true 
  }
}

data "oci_core_vnic_attachments" "FoggyKitchenJenkins_VNIC1_attach" {
  availability_domain = lookup(data.oci_identity_availability_domains.ADs.availability_domains[1], "name")
  compartment_id = oci_identity_compartment.FoggyKitchenCompartment.id
  instance_id = oci_core_instance.FoggyKitchenJenkins.id
}

data "oci_core_vnic" "FoggyKitchenJenkins_VNIC1" {
  vnic_id = data.oci_core_vnic_attachments.FoggyKitchenJenkins_VNIC1_attach.vnic_attachments.0.vnic_id
}


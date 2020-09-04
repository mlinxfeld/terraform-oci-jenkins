resource "null_resource" "FoggyKitchenJenkisSetup" {
 depends_on = [oci_core_instance.FoggyKitchenJenkins]
 provisioner "remote-exec" {
        connection {
                type     = "ssh"
                user     = "opc"
		host     = data.oci_core_vnic.FoggyKitchenJenkins_VNIC1.public_ip_address
                private_key = file(var.private_key_oci)
                script_path = "/home/opc/myssh.sh"
                agent = false
                timeout = "10m"
        }
  inline = ["sudo -u root yum -y install java-1.8.0-openjdk-devel",
            "sudo /bin/su -c \"curl --silent --location http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo | sudo tee /etc/yum.repos.d/jenkins.repo\"", 
            "sudo -u root rpm --import https://pkg.jenkins.io/redhat/jenkins.io.key",
            "sudo -u root yum install -y jenkins", 
            "sudo -u root systemctl start jenkins",
            "sudo -u root systemctl status jenkins",
            "sudo -u root systemctl enable jenkins",
            "sudo -u root firewall-cmd --permanent --zone=public --add-port=8080/tcp",
            "sudo -u root firewall-cmd --reload",
            "sudo -u root curl http://localhost:8080"
           ] 
  }
}

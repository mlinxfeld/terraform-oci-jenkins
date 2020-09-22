resource "null_resource" "FoggyKitchenJenkisSetup" {
 depends_on = [oci_core_instance.FoggyKitchenJenkins]
 
 provisioner "remote-exec" {
        connection {
                type        = "ssh"
                user        = "opc"
		            host        = data.oci_core_vnic.FoggyKitchenJenkins_VNIC1.public_ip_address
                private_key = tls_private_key.public_private_key_pair.private_key_pem
                script_path = "/home/opc/myssh.sh"
                agent       = false
                timeout     = "10m"
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
            "sudo -u root touch /var/lib/jenkins/.last_exec_version",
            "sudo /bin/su -c \"echo '2.0' | sudo tee /var/lib/jenkins/upgraded\"",
            "sudo -u root sleep 30s",
           ] 
  }
}


resource "null_resource" "FoggyKitchenJenkisDisableSetupWizard" {
  depends_on = [null_resource.FoggyKitchenJenkisSetup]
  
  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenJenkins_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "scripts/basic-security.groovy_INITIAL_SETUP_COMPLETED"
    destination = "/tmp/basic-security.groovy"
  }

  provisioner "file" {
    connection {
      type        = "ssh"
      user        = "opc"
      host        = data.oci_core_vnic.FoggyKitchenJenkins_VNIC1.public_ip_address
      private_key = tls_private_key.public_private_key_pair.private_key_pem
      script_path = "/home/opc/myssh.sh"
      agent       = false
      timeout     = "10m"
    }
    source      = "scripts/jenkins_config"
    destination = "/tmp/jenkins_config"
  }

  provisioner "remote-exec" {
        connection {
                type        = "ssh"
                user        = "opc"
                host        = data.oci_core_vnic.FoggyKitchenJenkins_VNIC1.public_ip_address
                private_key = tls_private_key.public_private_key_pair.private_key_pem
                script_path = "/home/opc/myssh.sh"
                agent       = false
                timeout     = "10m"
        }
  inline = ["sudo -u root mv /tmp/jenkins_config /etc/sysconfig/jenkins",
            "sudo -u root mkdir /var/lib/jenkins/init.groovy.d",
            "sudo -u root mv /tmp/basic-security.groovy /var/lib/jenkins/init.groovy.d/",
            "sudo -u root systemctl stop jenkins",
            "sudo -u root systemctl start jenkins",
            "echo '****************************'",
            "echo 'Jenkins admin user password:'",
            "echo '****************************'",
            "sudo -u root cat /var/lib/jenkins/secrets/initialAdminPassword",
            "echo '****************************'"
            ]
   }
}


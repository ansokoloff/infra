provider "google" {
  project = "601394049364"
  region  = "europe-west4"
  zone    = "europe-west4-a"
}

terraform {
  required_version = ">= v1.1.8"
  backend "gcs" {
    bucket = "bucketforepam"
    prefix  = "terraform/state"
  }
}


provider "tls" {
  // no config needed
}

resource "google_compute_firewall" "default" {
    name    = "final-task"
    network = "default"

    allow {
        protocol        = "tcp"
        ports           = ["80", "8080", "22"]
    }

    source_ranges   = ["0.0.0.0/0"]

}

# resource "tls_private_key" "key01" {
#   algorithm   = "RSA"
#   rsa_bits = "2048"
# }

resource "google_compute_instance" "control" {
    name            = "dockerfarm"
    machine_type = "n1-standard-1"
    zone         = "europe-west4-a"

  boot_disk {
    auto_delete = true
    initialize_params {
      image  = "https://www.googleapis.com/compute/v1/projects/cloud-infra-services-public/global/images/dockercompose-ubun20-03122020"
      labels = {}
      size   = 10
      type   = "pd-standard"
        }    
  }

  network_interface {
    network = "default"
    access_config {
            # Ephemeral
    }
  }

  metadata = {
    # ssh-keys = "ubuntu:${tls_private_key.key01.public_key_openssh}"
    ssh-keys = "arctic:${file("epam_rsa.pub")}"
  }

  connection {
    user        = "arctic"
    private_key = "${file("epam_rsa")}"
    host        = "${google_compute_instance.control.network_interface.0.access_config.0.nat_ip}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt -y install ansible"   
    ]
  }    


}

# resource "google_compute_instance" "master" {
#   depends_on      = [ google_compute_instance.node ]   
#   name         = "master"
#   machine_type = "n1-standard-1"
#   zone         = "europe-west2-a"

#   boot_disk {
#     auto_delete = true
#     initialize_params {
#       image  = "https://www.googleapis.com/compute/v1/projects/cloud-infra-services-public/global/images/dockercompose-ubun20-03122020"
#       labels = {}
#       size   = 10
#       type   = "pd-standard"
#         }    
#   }
  
#   network_interface {
#     network = "default"
#     access_config {
#             # Ephemeral
#         }
#     }    
#   metadata = {
#     # ssh-keys = "ubuntu:${tls_private_key.key01.public_key_openssh}"
#     ssh-keys = "arctic:${file("key.pub")}"
#     }   
# }
#   connection {
#     user        = "ubuntu"
#     private_key = "${tls_private_key.key01.private_key_pem}"
#     host        = "${google_compute_instance.master.network_interface.0.access_config.0.nat_ip}"
#   }

#   provisioner "remote-exec" {
#     inline = [
#       "sudo service docker start",
#       "sudo docker swarm init",
#       "echo '#!/bin/bash' > join.sh",
#       "TOKEN=`sudo docker swarm join-token -q worker`; echo \"docker swarm join --token $TOKEN ${self.network_interface.0.network_ip}:2377\" >> join.sh",
#       "mkdir .ssh",
#       "echo \"${tls_private_key.key01.private_key_pem}\" > .ssh/key; chmod 700 .ssh/; chmod 600 .ssh/key",
#       "scp -i .ssh/key -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" join.sh ubuntu@${google_compute_instance.node.0.network_interface.0.access_config.0.nat_ip}:",
#       "scp -i .ssh/key -o \"StrictHostKeyChecking no\" -o \"UserKnownHostsFile /dev/null\" join.sh ubuntu@${google_compute_instance.node.1.network_interface.0.access_config.0.nat_ip}:",
#       "rm .ssh/key"    
#     ]
#   }    

#   provisioner "file" { 
#     source      = "docker-compose.yml"
#     destination = "/tmp/docker-compose.yml"
#   }

# }

# resource "null_resource" "swarm-node-0" {
#   depends_on = [ google_compute_instance.master ] 
#   connection {
#     user        = "ubuntu"
#     private_key = "${tls_private_key.key01.private_key_pem}"
#     host        = "${google_compute_instance.node.0.network_interface.0.access_config.0.nat_ip}"
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo service docker start",
#       "chmod +x /home/ubuntu/join.sh",
#       "sudo /home/ubuntu/join.sh"
#     ]
#   }
# }

# resource "null_resource" "swarm-node-1" {
#   depends_on = [ null_resource.swarm-node-0 ] 
#   connection {
#     user        = "ubuntu"
#     private_key = "${tls_private_key.key01.private_key_pem}"
#     host        = "${google_compute_instance.node.1.network_interface.0.access_config.0.nat_ip}"
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo service docker start",
#       "chmod +x /home/ubuntu/join.sh",
#       "sudo /home/ubuntu/join.sh"
#     ]
#   }
# }

# resource "null_resource" "compose" {
#   depends_on = [ null_resource.swarm-node-1 ] 
#   connection {
#     user        = "ubuntu"
#     private_key = "${tls_private_key.key01.private_key_pem}"
#     host        = "${google_compute_instance.master.network_interface.0.access_config.0.nat_ip}"
#   }
#   provisioner "remote-exec" {
#     inline = [
#       "sudo docker-compose -f /tmp/docker-compose.yml pull",
#       "sudo docker stack deploy --with-registry-auth -c /tmp/docker-compose.yml task"
#     ]
#   }
# }

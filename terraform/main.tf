# main.tf (Terraform)
resource "google_compute_firewall" "allow_k3s" {
  name    = "allow-k3s-traffic"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["6443", "10250", "20"]
  }

  allow {
    protocol = "udp"
    ports    = ["8472", "51820"]
  }

  source_ranges = ["10.0.0.0/24"]  
}
resource "google_compute_firewall" "allow_mongodb" {
  name    = "allow-mongodb"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["27017"]
  }

  source_ranges = ["10.0.0.0/24"]  
}

resource "google_compute_router" "nat_router" {
  name    = "k3s-nat-router"
  network = google_compute_network.vpc_network.id
  region  = "europe-west1"
}

resource "google_compute_router_nat" "nat" {
  name                               = "k3s-nat"
  router                             = google_compute_router.nat_router.name
  region                             = google_compute_router.nat_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  
}
resource "google_compute_firewall" "allow_egress_internet" {
  name    = "allow-egress-internet"
  network = google_compute_network.vpc_network.id

  direction = "EGRESS"

  allow {
    protocol = "all"
  }

  destination_ranges = ["0.0.0.0/0"]
}

resource "google_compute_network" "vpc_network" {
  name = "k3s-private-network"
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "k3s-private-subnet"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.0.0.0/24"
}
resource "google_compute_address" "proxy_ip" {
  name   = "proxy-ip"
  region = "europe-west1"
  
}
resource "google_compute_instance" "k3s_master" {
  name         = "k3s-master"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.private_subnet.id
	access_config {
      nat_ip = google_compute_address.proxy_ip.address
    }
  }
}

resource "google_compute_instance" "k3s_nodes" {
  count        = 3
  name         = "k3s-node-${count.index}"
  machine_type = "e2-medium"
  zone         = "europe-west1-b"

  boot_disk {
    initialize_params {
      image = "rocky-linux-cloud/rocky-linux-9"
      size  = 20
    }
  }

  network_interface {
    network    = google_compute_network.vpc_network.id
    subnetwork = google_compute_subnetwork.private_subnet.id
  }
}


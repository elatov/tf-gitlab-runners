provider "google" {
  credentials = file("credentials.json")
  project     = var.gcp_project
  zone        = var.gcp_zone
  region      = var.gcp_region
}
# Create the Gitlab CI Runner instance.
resource "google_compute_instance" "ci_runner" {
  project      = var.gcp_project
  name         = "gitlab-ci-runner"
  machine_type = var.ci_runner_instance_type
  zone         = var.gcp_zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-1804-lts"
      size  = "10"
      type  = "pd-standard"
    }
  }

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  service_account {
    # scopes = ["cloud-platform"]
    scopes = ["storage-rw", "logging-write", "monitoring-write", "pubsub", "service-management", "service-control"]
  }

  metadata_startup_script = <<SCRIPT
set -e
echo "Installing GitLab CI Runner"
curl -L https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | sudo bash
sudo apt remove -y --purge man-db
sudo apt install -y gitlab-runner
echo "Installing Docker"
sudo apt install -y apt-transport-https ca-certificates curl \
    gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) stable"
sudo apt update
sudo ln -s /snap/google-cloud-sdk/current/bin/docker-credential-gcloud /snap/bin/
sudo apt install -y docker-ce docker-ce-cli containerd.io
sudo usermod -aG docker gitlab-runner
sudo gcloud auth configure-docker --quiet
echo "Registering GitLab CI runner with GitLab instance."
sudo gitlab-runner register \
    --non-interactive \
    --name "gcp-${var.gcp_project}" \
    --url ${var.gitlab_url} \
    --registration-token ${var.ci_token} \
    --executor "docker" \
    --docker-image alpine:latest \
    --tag-list "docker,gce,specific" \
    --run-untagged="true" \
    --locked="false" \
    --access-level="not_protected"
echo "GitLab CI Runner installation complete"
SCRIPT

}

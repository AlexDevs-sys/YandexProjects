resource "yandex_compute_disk" "boot-disk" {
  for_each = var.virtual_machines
  name     = each.value["disk_name"]
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = each.value["disk"]
  image_id = each.value["template"]
}

resource "yandex_vpc_network" "network-1" {
  name = "network123"
}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "subnet123"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "virtual_machine" {
  for_each        = var.virtual_machines
  name = each.value["vm_name"]

  resources {
    cores  = each.value["vm_cpu"]
    memory = each.value["ram"]
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[each.key].id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true
  }

    metadata = {
     ssh-keys = "alex:${file("~/.ssh/yandex_cloud_key.pub")}"
   }
}


output "vm_ip" {
  value = { for k, v in  yandex_compute_instance.virtual_machine : k => v.network_interface.0.ip_address }
}

output "vm_nat_ip" {
  value = { for k, v in  yandex_compute_instance.virtual_machine : k => v.network_interface.0.nat_ip_address}
} 

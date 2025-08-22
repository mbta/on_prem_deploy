# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  vm_name = ENV["VAGRANT_HOSTNAME"] || "vagrant"

  config.vagrant.plugins = ["vagrant-env", "vagrant-vbguest"]
  config.env.enable # enable .env support plugin (it will let us easily enable cloud_init support)
  config.vbguest.auto_update = false

  config.vm.box = "ubuntu/jammy64"

  config.vm.define vm_name

  config.vm.hostname = vm_name

  config.vm.provider "virtualbox" do |vb|
    vb.name = vm_name

    # show GUI if building an arrival screen
    if vm_name.start_with?("SCREEN")
      vb.gui = true
    end

    # Customize the amount of memory on the VM:
    vb.memory = "1024"
  end

  # disable folder syncing
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.cloud_init :user_data do |cloud_init|
    cloud_init.content_type = "text/cloud-config"
    cloud_init.inline = <<-EOF
#{`bash build_vm_user_data.sh`}
hostname: #{vm_name}
EOF
  end
end

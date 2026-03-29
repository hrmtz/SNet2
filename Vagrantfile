# SNet2 - Evade the Watchers
# Usage: vagrant up
#
# Prerequisites:
#   - VirtualBox 7.0+
#   - Vagrant (https://developer.hashicorp.com/vagrant/install)
#   - Anthropic API key for the AI trainer
#
# WSL2 users: install Vagrant inside WSL (Linux binary), not Windows.
#   export VAGRANT_WSL_ENABLE_WINDOWS_ACCESS="1"
#   export PATH="$PATH:/mnt/c/Program Files/Oracle/VirtualBox"
#
# To start only specific VMs:
#   vagrant up claude kali target   # skip zabbix (attack phase only)
#   vagrant up                      # all VMs (attack + defense)

Vagrant.configure("2") do |config|

  # Disable default synced folder (not needed, avoids guest additions dependency)
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # --- AI Trainer (Claude Code) ---
  config.vm.define "claude", primary: true do |c|
    # c.vm.box = "hrmtz/snet-claude"
    c.vm.box = "snet-claude"
    c.vm.box_url = "https://github.com/hrmtz/SNet/releases/download/v1.1.0/snet-claude.box"
    c.vm.hostname = "cage"
    c.vm.network "private_network", ip: "10.0.2.5", virtualbox__intnet: "SNet2-Net"
    c.vm.network "forwarded_port", guest: 22, host: 2222, id: "claude-ssh"
    c.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "SNet-Claude"
      vb.gui = false
    end
    c.ssh.username = "snet"
    c.ssh.password = "snet"
    c.ssh.insert_key = true
  end

  # --- Kali Linux (attacker) ---
  config.vm.define "kali" do |k|
    k.vm.box = "kalilinux/rolling"
    k.vm.hostname = "kali"
    k.vm.network "private_network", ip: "10.0.2.10", virtualbox__intnet: "SNet2-Net"
    k.vm.network "forwarded_port", guest: 22, host: 2223, id: "kali-ssh"
    k.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 2
      vb.name = "SNet-Kali"
      vb.gui = false
    end
  end

  # --- Target (monitored server) ---
  # Target box is split into 3 parts on GitHub Releases due to 2GB limit.
  config.vm.define "target" do |t|
    # t.vm.box = "hrmtz/snet2-target"
    t.vm.box = "snet2-target"
    t.vm.hostname = "target"
    t.vm.network "private_network", ip: "10.0.2.20", virtualbox__intnet: "SNet2-Net"
    t.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
      vb.name = "SNet2-Target"
      vb.gui = false
    end

    t.trigger.before :up do |trigger|
      trigger.name = "Download target box"
      trigger.ruby do |env, machine|
        box_exists = system("vagrant box list | grep -q 'snet2-target'")
        unless box_exists
          puts "Downloading and assembling snet2-target box..."
          base_url = "https://github.com/hrmtz/SNet2/releases/download/v1.1.0"
          %w[aa ab ac].each { |p| system("curl -L -o /tmp/snet2-target.part-#{p} '#{base_url}/snet2-target.box.part-#{p}'") }
          system("cat /tmp/snet2-target.part-aa /tmp/snet2-target.part-ab /tmp/snet2-target.part-ac > /tmp/snet2-target.box")
          system("vagrant box add snet2-target /tmp/snet2-target.box")
          system("rm -f /tmp/snet2-target.part-* /tmp/snet2-target.box")
        end
      end
    end
  end

  # --- Zabbix (monitoring server) ---
  # Zabbix box is split into 3 parts on GitHub Releases due to 2GB limit.
  config.vm.define "zabbix" do |z|
    # z.vm.box = "hrmtz/snet2-zabbix"
    z.vm.box = "snet2-zabbix"
    z.vm.hostname = "zabbix"
    z.vm.network "private_network", ip: "10.0.2.30", virtualbox__intnet: "SNet2-Net"
    z.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "SNet2-Zabbix"
      vb.gui = false
    end

    z.trigger.before :up do |trigger|
      trigger.name = "Download zabbix box"
      trigger.ruby do |env, machine|
        box_exists = system("vagrant box list | grep -q 'snet2-zabbix'")
        unless box_exists
          puts "Downloading and assembling snet2-zabbix box..."
          base_url = "https://github.com/hrmtz/SNet2/releases/download/v1.1.0"
          %w[aa ab ac].each { |p| system("curl -L -o /tmp/snet2-zabbix.part-#{p} '#{base_url}/snet2-zabbix.box.part-#{p}'") }
          system("cat /tmp/snet2-zabbix.part-aa /tmp/snet2-zabbix.part-ab /tmp/snet2-zabbix.part-ac > /tmp/snet2-zabbix.box")
          system("vagrant box add snet2-zabbix /tmp/snet2-zabbix.box")
          system("rm -f /tmp/snet2-zabbix.part-* /tmp/snet2-zabbix.box")
        end
      end
    end
  end

end

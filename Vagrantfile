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
    c.vm.box = "hrmtz/snet-claude"
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
  config.vm.define "target" do |t|
    t.vm.box = "hrmtz/snet2-target"
    t.vm.hostname = "target"
    t.vm.network "private_network", ip: "10.0.2.20", virtualbox__intnet: "SNet2-Net"
    t.vm.provider "virtualbox" do |vb|
      vb.memory = 512
      vb.cpus = 1
      vb.name = "SNet2-Target"
      vb.gui = false
    end
  end

  # --- Zabbix (monitoring server) ---
  config.vm.define "zabbix" do |z|
    z.vm.box = "hrmtz/snet2-zabbix"
    z.vm.hostname = "zabbix"
    z.vm.network "private_network", ip: "10.0.2.30", virtualbox__intnet: "SNet2-Net"
    z.vm.provider "virtualbox" do |vb|
      vb.memory = 1024
      vb.cpus = 1
      vb.name = "SNet2-Zabbix"
      vb.gui = false
    end
  end

end

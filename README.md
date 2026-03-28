# SNet2 - Evade the Watchers

[Japanese version / 日本語版はこちら](README_ja.md)

> You broke in. Now stay hidden.

**SNet2** is the second installment of the [SNet CTF series](https://github.com/hrmtz/SNet). While SNet1 taught you how to break into a poorly managed server, SNet2 challenges you to **operate under active surveillance** — a Zabbix monitoring system watches every file change, every process, every login. Your mission: maintain persistent access without triggering a single alert.

Then flip sides and build the defenses yourself.

## The Challenge

The target server is monitored 24/7. Checksums are verified every 30 seconds. Logs are analyzed in real-time. And yet, every monitoring system has blind spots — if you know where to look.

This CTF is based on a real server. The vulnerabilities are not hypothetical.

## Structure

| Round | Phase | Goal |
|-------|-------|------|
| 1-3 | **Attack** | Evade monitoring while maintaining persistence |
| 4-6 | **Defense** | Build detection systems that catch the attacks you just performed |

Attack like an intruder. Defend like a sysadmin. Understand both sides of the wire.

## Requirements

- PC with 12GB+ RAM (4 VMs running simultaneously)
- [VirtualBox](https://www.virtualbox.org/) 7.0+
- Anthropic API key ([console.anthropic.com](https://console.anthropic.com/))

## Download

Download all OVAs from [Releases](https://github.com/hrmtz/SNet2/releases):

| OVA | Role | Size |
|-----|------|------|
| `SNet-Claude.ova` | AI Trainer (Claude Code) | ~300 MB |
| `SNet2-Target.ova` | Monitored target server | ~1 GB |
| `SNet2-Zabbix.ova` | Zabbix monitoring server | ~1.2 GB |

You also need a Kali Linux VM:
- If you completed SNet1, reuse the same Kali (SNet2 installs as an add-on)
- Otherwise, download from [kali.org](https://www.kali.org/get-kali/#kali-virtual-machines)

> Already have `SNet-Claude.ova` from SNet1? **Use the same one.** Just switch its NIC to `SNet2-Net` — it auto-configures on boot.

## Setup

### OVA Import + Manual Network

1. Import all `.ova` files into VirtualBox (default settings)
2. Create the network (once per setup):

```bash
VBoxManage natnetwork add --netname "SNet2-Net" --network "10.0.2.0/24" --enable --dhcp on
VBoxManage natnetwork modify --netname "SNet2-Net" --port-forward-4 "claude-ssh:tcp:[]:2222:[10.0.2.5]:22"
VBoxManage natnetwork modify --netname "SNet2-Net" --port-forward-4 "kali-ssh:tcp:[]:2223:[10.0.2.10]:22"
```

3. Start all VMs:

```bash
VBoxManage startvm "SNet-Claude" --type headless
VBoxManage startvm "SNet-Kali" --type headless
```

Start Target and Zabbix normally (or headless — your choice).

4. Connect to the trainer:

```bash
ssh -p 2222 snet@localhost
```

Default password: `snet`. On first login, enter your Anthropic API key. Claude Code starts automatically.

5. Follow your trainer — Claude handles Kali setup, network config, and game progression.

### With Vagrant

```bash
git clone https://github.com/hrmtz/SNet2.git
cd SNet2
vagrant up
```

All VMs, networking, and port forwarding — one command. Connect with `vagrant ssh claude` or `ssh -p 2222 snet@localhost`.

### Without AI Trainer

Import Target and Zabbix OVAs. Set up networking with your Kali. Hack away — no trainer needed.

### Need help with setup?

If VBoxManage commands or NAT networking feels daunting, you can ask Claude Code on your host machine to do it for you. Just run `claude` in any directory and paste this:

> I downloaded SNet2-Target.ova, SNet2-Zabbix.ova, and SNet-Claude.ova for the SNet2 CTF. Please import them into VirtualBox, create a NAT network called "SNet2-Net" (10.0.2.0/24) with port forwards for SSH (host 2222 → 10.0.2.5:22, host 2223 → 10.0.2.10:22), attach all VMs to it, and start them.

Claude Code on your machine runs with normal permissions — it will ask before running each command.

## What You'll Learn

### Attack Phase
- How agent-based monitoring works — and where it breaks
- Timing attacks against periodic integrity checks
- Selective log manipulation
- The difference between "alive" and "watching"

### Defense Phase
- Remote syslog forwarding (tamper-proof logging)
- File integrity monitoring (AIDE/Tripwire)
- Kernel-level auditing with auditd
- Agentless monitoring — when you can't trust the agent

## Key Lesson

> "Don't trust the agent. Trust the kernel."
>
> When an attacker has root, application-level monitoring is compromised.
> Only kernel-level controls and external logging survive.

## Series

```
SNet1 = Breaking into an unlocked house     (Beginner)
SNet2 = Staying hidden from the guards      (Intermediate)
```

Completing SNet1 first is recommended but not required. SNet1 veterans may discover things that others won't.

SNet2 installs as an add-on — if you already have the Kali VM and Claude OVA from SNet1, just add the Target and Zabbix OVAs.

## Credits

Created by [@hrmtz](https://github.com/hrmtz) | Built with [Claude Code](https://claude.ai/claude-code)

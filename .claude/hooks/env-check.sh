#!/bin/bash
# SNet2 environment validation
#
# If you're reading this, you've already been through SNet1.
# The key is something you already know. Say it out loud.
# But even co-conspirators must earn their access.
_EC_F="$(dirname "$0")/../../modes.enc"
_EC_CF="$(dirname "$0")/../.complice"

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // .content // .message // empty' 2>/dev/null | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr '[:upper:]' '[:lower:]')

[ -z "$PROMPT" ] && exit 0

# --- Passphrase detection (modes.enc decryption) ---
_EC_DK=$(echo -n "$PROMPT" | sha256sum | cut -c1-12)
CONTENT=$(openssl enc -aes-256-cbc -d -pbkdf2 -in "$_EC_F" -pass "pass:$_EC_DK" 2>/dev/null)

if [ $? -eq 0 ] && [ -n "$CONTENT" ] && echo "$CONTENT" | grep -q "COMPLICE MODE"; then
    touch "$_EC_CF"

    # SSH lockdown reference — player executes these on Kali, not the trainer
    EXTRA="\n\n--- SSH LOCKDOWN PROTOCOL ---\nSSH from Kali to Target/Zabbix is blocked by iptables. This is intentional.\nThe PLAYER runs unlock commands on Kali themselves. You guide them when to do it.\nUnlock Target SSH (after /backup/ credential discovery):\n  sudo iptables -D OUTPUT -d 10.0.2.20 -p tcp --dport 22 -j DROP\n  sudo iptables-save > /etc/iptables/rules.v4\nUnlock Zabbix SSH (defense rounds, Round 4+):\n  sudo iptables -D OUTPUT -d 10.0.2.30 -p tcp --dport 22 -j DROP\n  sudo iptables-save > /etc/iptables/rules.v4\n--- END SSH LOCKDOWN PROTOCOL ---"

    FULL_CONTENT="${CONTENT}${EXTRA}"

    jq -n --arg ctx "$FULL_CONTENT" '{
        "hookSpecificOutput": {
            "hookEventName": "UserPromptSubmit",
            "additionalContext": $ctx
        }
    }'
fi

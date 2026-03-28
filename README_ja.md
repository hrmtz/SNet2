# SNet2 - 監視を欺け

[English version](README.md)

> 侵入した。で、どうする？

**SNet2**は[SNet CTFシリーズ](https://github.com/hrmtz/SNet)の第2弾。SNet1でずさん管理のサーバーへの侵入を学んだあなたに、次の課題 ── **Zabbixで24時間監視されているサーバーに、バレずに居座る**。

そして立場を入れ替え、自分で防御を構築する。

## チャレンジ

ターゲットサーバーは常時監視されている。チェックサムは30秒ごとに検証。ログはリアルタイムで分析。それでも、すべての監視システムには死角がある ── どこを見ればいいか知っていれば。

このCTFは実在したサーバーがベースになっている。脆弱性は架空のものではない。

## 構成

| ラウンド | フェーズ | 目標 |
|----------|----------|------|
| 1-3 | **攻撃** | 監視を欺きながら永続的アクセスを維持 |
| 4-6 | **防御** | 自分が仕掛けた攻撃を検知する仕組みを構築 |

侵入者として攻撃し、管理者として守る。ワイヤーの両面を理解せよ。

## 必要環境

- RAM 12GB以上のPC（VM4台を同時起動）
- [VirtualBox](https://www.virtualbox.org/) 7.0以上
- Anthropic APIキー（[console.anthropic.com](https://console.anthropic.com/)）

## ダウンロード

[Releases](https://github.com/hrmtz/SNet2/releases)から全OVAをダウンロード：

| OVA | 役割 | サイズ |
|-----|------|--------|
| `SNet-Claude.ova` | AIトレーナー（Claude Code） | ~300 MB |
| `SNet2-Target.ova` | 監視対象のターゲットサーバー | ~1 GB |
| `SNet2-Zabbix.ova` | Zabbix監視サーバー | ~1.2 GB |

Kali Linux VMも必要：
- SNet1クリア済みなら同じKaliを再利用（SNet2はアドオンとしてインストール）
- なければ[kali.org](https://www.kali.org/get-kali/#kali-virtual-machines)からダウンロード

> SNet1で`SNet-Claude.ova`を持っている？ **そのまま使える。** NICを`SNet2-Net`に切替えるだけ — 起動時にIPが自動設定される。

## セットアップ

### OVAインポート + 手動ネットワーク設定

1. 各`.ova`ファイルをVirtualBoxにインポート（デフォルト設定でOK）
2. ネットワーク作成（初回のみ）：

```bash
VBoxManage natnetwork add --netname "SNet2-Net" --network "10.0.2.0/24" --enable --dhcp on
VBoxManage natnetwork modify --netname "SNet2-Net" --port-forward-4 "claude-ssh:tcp:[]:2222:[10.0.2.5]:22"
VBoxManage natnetwork modify --netname "SNet2-Net" --port-forward-4 "kali-ssh:tcp:[]:2223:[10.0.2.10]:22"
```

3. 全VM起動：

```bash
VBoxManage startvm "SNet-Claude" --type headless
VBoxManage startvm "SNet-Kali" --type headless
```

TargetとZabbixは通常起動でもヘッドレスでもOK。

4. トレーナーに接続：

```bash
ssh -p 2222 snet@localhost
```

デフォルトパスワード: `snet`。初回ログイン時にAnthropic APIキーを入力。Claude Codeが自動起動する。

5. トレーナーに従え — ClaudeがKaliセットアップ、ネットワーク構成、ゲーム進行を担当する。

### Vagrantで一発

```bash
git clone https://github.com/hrmtz/SNet2.git
cd SNet2
vagrant up
```

全VM、ネットワーク、ポートフォワード — コマンド1つ。`vagrant ssh claude`または`ssh -p 2222 snet@localhost`で接続。

### AIトレーナーなし

TargetとZabbixのOVAをインポート。Kaliとネットワークを繋げるだけ。トレーナーなしでも遊べる。

### セットアップが難しい？

VBoxManageコマンドやNATネットワーク設定が面倒なら、ホストマシンのClaude Codeに任せられる。適当なディレクトリで`claude`を起動して、これを貼り付けるだけ：

> SNet2-Target.ova、SNet2-Zabbix.ova、SNet-Claude.ovaをダウンロードしました。VirtualBoxにインポートして、SNet2-Net（10.0.2.0/24）というNATネットワークを作成し、SSHのポートフォワード（ホスト2222→10.0.2.5:22、ホスト2223→10.0.2.10:22）を設定して、全VMを起動してください。

ホスト上のClaude Codeは通常の権限で動作する — コマンド実行前に毎回確認が入る。

## 学べること

### 攻撃フェーズ
- エージェントベース監視の仕組み ── そしてどこで壊れるか
- 定期チェックに対するタイミング攻撃
- ログの選択的操作
- 「生きている」と「見ている」の違い

### 防御フェーズ
- リモートsyslog転送（改ざん不可ロギング）
- ファイル整合性監視（AIDE/Tripwire）
- カーネルレベル監査（auditd）
- エージェントレス監視 ── エージェントを信用できないとき

## 教訓

> 「エージェントを信用するな。カーネルを信用しろ。」
>
> 攻撃者がrootを取ったら、アプリケーションレベルの監視は無力。
> カーネルレベルの制御と外部ロギングだけが生き残る。

## シリーズ

```
SNet1 = 鍵かけ忘れた家に入る     （初級）
SNet2 = 警備員の目を盗んで居座る  （中級）
```

SNet1を先にクリアすることを推奨するが、必須ではない。SNet1経験者には、他の人には見えないものが見えるかもしれない。

SNet2はアドオン — SNet1のKali VMとClaude OVAがあれば、TargetとZabbixのOVAを追加するだけ。

## クレジット

[@hrmtz](https://github.com/hrmtz) | [Claude Code](https://claude.ai/claude-code)で構築

# AI エージェントワークショップ — 環境準備ガイド

## 前提条件

- AWS アカウント（マネジメントコンソールにログインできること）
- VS Code Server（ブラウザで開ける状態）
- Amazon Q Developer 拡張機能がインストール済み

---

## 準備 1 / 4：アクセスキーの発行（AWS CloudShell）

AWS CloudShell でスクリプトを実行し、IAM ユーザー・ポリシー・アクセスキーを一括作成します。

### 手順

1. [AWS マネジメントコンソール](https://console.aws.amazon.com) にログイン
2. 上部の検索バーで「**CloudShell**」を検索 → 開く
3. 以下のコマンドを順番に実行

```bash
git clone https://github.com/nemf/ai-agent-workshop.git
cd ai-agent-workshop
chmod +x script.sh
./script.sh
```

4. 出力された **AccessKeyId** と **SecretAccessKey** をメモ・保存

```json
{
  "AccessKey": {
    "UserName": "bedrock-agent-dev",
    "AccessKeyId": "AKIA...",
    "SecretAccessKey": "...",
    "Status": "Active"
  }
}
```

> ⚠️ **SecretAccessKey は再表示できません。** スクリプト実行直後に必ずメモしてください。紛失した場合はキーを削除して再発行が必要です。

### スクリプトが自動で行うこと

| ステップ | 内容 |
|---------|------|
| 1 | IAM ユーザー `bedrock-agent-dev` を作成 |
| 2 | カスタムポリシー `AIAgentWorkshopPolicy` を作成（Allow + Deny） |
| 3 | ポリシーをユーザーにアタッチ |
| 4 | アクセスキーを発行 |

---

## 準備 2 / 4：AWS CLI の設定（VS Code Server）

VS Code Server のターミナルでアクセスキーを登録します。

### 手順

1. VS Code Server をブラウザで開く
2. 上部メニュー「**ターミナル**」→「**新しいターミナル**」
3. 以下を実行

```bash
aws configure --profile bedrock-dev
```

4. 4 つの質問に回答

| 質問 | 入力する値 |
|------|-----------|
| AWS Access Key ID | CloudShell で取得した `AKIA...` |
| AWS Secret Access Key | CloudShell で取得したシークレットキー |
| Default region name | `us-west-2` |
| Default output format | `json` |

5. プロファイルを有効化

```bash
export AWS_PROFILE=bedrock-dev
```

6. （推奨）ターミナル起動時に自動で有効化

```bash
echo 'export AWS_PROFILE=bedrock-dev' >> ~/.bashrc
source ~/.bashrc
```

7. 設定確認

```bash
aws sts get-caller-identity
```

`"Arn"` に `bedrock-agent-dev` が含まれていれば OK。

---

## 準備 3 / 4：MCP サーバーの設定

Amazon Q Developer に 3 つの MCP サーバーを接続し、開発効率を上げます。

### 前提：uv のインストール

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### 手順

プロジェクトディレクトリ直下に `.amazonq/mcp.json` を作成します。

```bash
mkdir -p .amazonq
curl -o .amazonq/mcp.json https://raw.githubusercontent.com/nemf/ai-agent-workshop/main/mcp.json
```

#### 設定内容

```json
{
  "mcpServers": {
    "aws-knowledge": {
      "url": "https://knowledge-mcp.global.api.aws",
      "type": "http",
      "disabled": false,
      "autoApprove": ["*"]
    },
    "bedrock-agentcore": {
      "command": "uvx",
      "args": ["awslabs.amazon-bedrock-agentcore-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "autoApprove": ["*"]
    },
    "aws-iac": {
      "command": "uvx",
      "args": ["awslabs.aws-iac-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      },
      "autoApprove": ["*"]
    }
  }
}
```

| サーバー | 種類 | 用途 |
|---------|------|------|
| AWS Knowledge | ☁ リモート | AWS ドキュメント・What's New・Blog・Agent SOPs |
| Bedrock AgentCore | ローカル | AgentCore ドキュメント検索 + クラウドブラウザツール |
| AWS IaC | ローカル | CDK/CloudFormation テンプレート検証・ベストプラクティス |

### 反映

VS Code のコマンドパレット（`Ctrl+Shift+P`）→ 「**Reload Window**」で Q Developer を再起動。

---

## 準備 4 / 4：amazonq.md の設定

プロジェクトルールを定義して、Q Developer にプロジェクトの文脈を理解させます。

### 手順

プロジェクトディレクトリ直下に `amazonq.md` を配置します。

```bash
curl -o amazonq.md https://raw.githubusercontent.com/nemf/ai-agent-workshop/main/amazonq.md
```

#### 主な設定内容

- **応答ルール** — 日本語で返答、コメントも日本語
- **使用ライブラリ** — strands-agents, strands-agents-tools, pytest, ruff
- **開発フロー** — コード → テスト → テスト実行 → README 更新
- **コーディング規約** — Python 3.12+、型ヒント必須、ruff format/check
- **モデル** — Claude Opus 4.6（`us.anthropic.claude-opus-4-6-v1`）

> 💡 `amazonq.md` はプロジェクトのルールブック。Q Developer がこのファイルを読んで、プロジェクトの文脈を理解した上でコードを書いてくれます。

---

## チェックリスト

準備が完了したら、以下を確認してください。

- [ ] `aws sts get-caller-identity` で `bedrock-agent-dev` が表示される
- [ ] `.amazonq/mcp.json` がプロジェクト直下にある
- [ ] `amazonq.md` がプロジェクト直下にある
- [ ] Q Developer のチャットで「AgentCore のドキュメントを検索して」と聞いて応答がある

すべて ✓ なら準備完了です。ワークショップを始めましょう！

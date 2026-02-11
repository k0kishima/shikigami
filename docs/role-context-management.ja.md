# ロール別コンテキスト管理

<p align='center'>
  <a href='./role-context-management.md'>English</a> | 日本語
</p>

## 目的

エージェントに渡すコンテキストをロール単位で制御し、トークン消費を最小化します。

### 背景

Shikigami でタスクフォースを生成する際、各エージェントにはロールテンプレート（`roles/` 配下）の内容が渡されます。
しかし、プロジェクト固有の情報をすべてのロールに一律で渡すと、不要なトークン消費が発生します。

例えば、React コンポーネントの命名規約や CSS 設計方針は Coder には必要ですが、バックエンド API の脆弱性を検査する SecurityEngineer には不要です。

### 解決策

プロジェクトの作業ディレクトリに `.shikigami/contexts/` ディレクトリを配置し、ロール名に対応するファイルを置きます。
オーケストレーターはエージェント spawn 時に該当ファイルの存在を確認し、存在すればその内容をロールテンプレートとともに prompt に含めます。

## 仕組み

### ディレクトリ構成

```
<作業ディレクトリ>/
  .shikigami/
    contexts/
      coder.md
      reviewer.md
      tester.md
      security_engineer.md
      performance_engineer.md
      system_architect.md
```

ファイル名は `roles/` ディレクトリのファイル名と完全一致させます。すべてのファイルを用意する必要はなく、必要なロールのファイルだけを配置します。

### オーケストレーターの動作

1. ロールテンプレートを読み込む（`$ROLES_DIR/{role_name}.md`）
2. `.shikigami/contexts/{role_name}.md` の存在を確認する
3. ファイルが存在すれば、その内容を読み込みロールテンプレートとともにエージェントの prompt に含める
4. ファイルが存在しなければ、ロールテンプレートのみで spawn する

### 外部ファイルの参照

コンテキストファイル内で外部ファイルを参照することで、複数ロール間での情報の重複を避けられます。

例えば、コーディング規約を Coder と Reviewer の両方に渡したい場合、規約本体を別ファイルとして管理し、各コンテキストファイルから参照します。

```markdown
# .shikigami/contexts/coder.md

## コーディング規約
docs/coding-standards.md を読んで遵守してください
```

```markdown
# .shikigami/contexts/reviewer.md

## コーディング規約
docs/coding-standards.md を読み、レビュー基準として使用してください
```

この方式では、spawn されたエージェントが自身の Read ツールを使って参照先のファイルを読み込みます。

## .gitignore への追加

`.shikigami/` は `.gitignore` に追加することを推奨します。
Shikigami を使用しないプロジェクトメンバーにとってノイズにならないようにするためです。

```gitignore
.shikigami/
```

チーム全員が Shikigami を使用する場合は、Git で管理しても構いません。

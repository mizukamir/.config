# ベースイメージ: Ubuntu 24.04 (M4 Macなら自動的にarm64版)
FROM ubuntu:24.04

# --- 引数設定 (ビルド時に変更可能) ---
ARG REPO_URL="https://github.com/mizumine/.config.git"
ARG FLAKE_TARGET="root"

# --- 1. 基本設定と依存関係のインストール ---
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV HOME=/root

# ロケール設定 (日本語化) と必須ツールのインストール
RUN apt-get update && apt-get install -y \
    curl \
    git \
    xz-utils \
    locales \
    sudo \
    && locale-gen ja_JP.UTF-8 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 環境変数の固定
ENV LANG=ja_JP.UTF-8
ENV LC_ALL=ja_JP.UTF-8

# --- 2. Nix (Determinate Systems) のインストール ---
# Docker内ではsystemdが動かないため --init none が必須
RUN curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | \
    sh -s -- install linux --init none --no-confirm

# これ以降のRUN命令でnixコマンドが使えるように
ENV PATH="${PATH}:/nix/var/nix/profiles/default/bin"

# Flakesを有効化
RUN mkdir -p /etc/nix && \
    echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# --- 3. 設定ファイル (Git) のクローン ---
# キャッシュを無効化して常に最新を取りたい場合は、ビルド時に --no-cache を使う
RUN git clone ${REPO_URL} /root/.config

# --- 4. Home Manager の適用 ---
# 作業ディレクトリを移動
WORKDIR /root/.config

# リポジトリ内の nix-docker ディレクトリにある flake.nix を指定
# 初回ビルド時にすべてのツール (Neovim, Zsh, Node.js等) がダウンロード・構築
RUN nix run home-manager/master -- switch --flake ./nix-docker#${FLAKE_TARGET}

# --- 5. ---
# 作業ディレクトリをホームに戻す
WORKDIR /root

# デフォルトシェルをzshに設定
CMD ["zsh"]

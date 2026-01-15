#!/bin/bash

# 現在の状態を取得
status=$(defaults read com.apple.finder CreateDesktop 2>/dev/null)

# "0" または "false" (大文字小文字無視) なら「隠れている」と判断
if [[ "$status" == "0" || "$status" =~ [Ff]alse ]]; then
    # 現在隠れている -> 表示する
    defaults write com.apple.finder CreateDesktop true
    echo "Desktop: Visible"
else
    # それ以外（"1", "true", または設定が存在しない） -> 隠す
    defaults write com.apple.finder CreateDesktop false
    echo "Desktop: Hidden"
fi

# Finderを再起動して反映
killall Finder

# Ingame Chat Foreground Fix

Fixes the weird overlap with the ingame chat and the champion current info hover information.

## What it changes

Overrides `asset/base/ui/layout/ingame` with a copy of base where `#chat_list` is
declared before `#champion_tooltip`, so the tooltip renders on top of chat instead
of underneath it. That move is the only difference from base.

## Base version

The layout is a snapshot of base **0.6.0-beta2**. When base changes `ingame.ui`, this
override has to be re-synced or the new nodes go missing: copy base's `ingame.ui`
and move the `#chat_list` block up to sit directly above `#champion_tooltip`.

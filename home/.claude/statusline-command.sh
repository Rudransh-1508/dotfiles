#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name')

used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx=""
[ -n "$used" ] && ctx=$(printf "ctx: %.0f%% used" "$used")

five=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
week=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
limits=""
if [ -n "$five" ]; then
  limits="5h: $(printf '%.0f' "$five")%"
fi
if [ -n "$week" ]; then
  if [ -n "$limits" ]; then
    limits="$limits | 7d: $(printf '%.0f' "$week")%"
  else
    limits="7d: $(printf '%.0f' "$week")%"
  fi
fi

out="$model"
[ -n "$ctx" ] && out="$out | $ctx"
[ -n "$limits" ] && out="$out | $limits"

printf "%s" "$out"

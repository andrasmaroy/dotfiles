#!/usr/bin/env bash

[[ -z "$PROFILE_NAME" ]] && PROFILE_NAME=andrasmaroy
[[ -z "$PROFILE_SLUG" ]] && PROFILE_SLUG=andrasmaroy
[[ -z "$DCONF" ]] && DCONF=dconf
[[ -z "$UUIDGEN" ]] && UUIDGEN=uuidgen

dset() {
  local key="$1"; shift
  local val="$1"; shift

  if [[ "$type" == "string" ]]; then
    val="'$val'"
  fi

  "$DCONF" write "$PROFILE_KEY/$key" "$val"
}

# because dconf still doesn't have "append"
dlist_append() {
  local key="$1"; shift
  local val="$1"; shift

  local entries="$(
    {
      "$DCONF" read "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
      echo "'$val'"
    } | head -c-1 | tr "\n" ,
  )"

  "$DCONF" write "$key" "[$entries]"
}

# Newest versions of gnome-terminal use dconf
if which "$DCONF" > /dev/null 2>&1; then
  [[ -z "$BASE_KEY_NEW" ]] && BASE_KEY_NEW=/org/gnome/terminal/legacy/profiles:

  if [[ -n "`$DCONF list $BASE_KEY_NEW/`" ]]; then
    if which "$UUIDGEN" > /dev/null 2>&1; then
      PROFILE_SLUG=`uuidgen`
    fi

    if [[ -n "`$DCONF read $BASE_KEY_NEW/default`" ]]; then
      DEFAULT_SLUG=`$DCONF read $BASE_KEY_NEW/default | tr -d \'`
    else
      DEFAULT_SLUG=`$DCONF list $BASE_KEY_NEW/ | grep '^:' | head -n1 | tr -d :/`
    fi

    DEFAULT_KEY="$BASE_KEY_NEW/:$DEFAULT_SLUG"
    PROFILE_KEY="$BASE_KEY_NEW/:$PROFILE_SLUG"

    # copy existing settings from default profile
    $DCONF dump "$DEFAULT_KEY/" | $DCONF load "$PROFILE_KEY/"

    # add new copy to list of profiles
    dlist_append $BASE_KEY_NEW/list "$PROFILE_SLUG"

# update profile values with theme options
dset visible-name "'$PROFILE_NAME'"
dset palette "['rgb(0,0,0)','rgb(242,119,122)','rgb(153,204,153)','rgb(255,204,102)','rgb(102,153,204)','rgb(204,153,204)','rgb(102,204,204)','rgb(255,255,255)','rgb(0,0,0)','rgb(242,119,122)','rgb(153,204,153)','rgb(255,204,102)','rgb(102,153,204)','rgb(204,153,204)','rgb(102,204,204)','rgb(255,255,255)']"
dset background-color "'rgb(45,45,45)'"
dset foreground-color "'rgb(204,204,204)'"
dset bold-color "'rgb(204,204,204)'"
dset bold-color-same-as-fg "false"
dset use-theme-colors "false"
dset login-shell "true"
dset custom-command "'/bin/bash -ilc tmux'"
if [[ -n $(find ~/.local/share/fonts /usr/share/fonts -name Menlo-Regular.ttf) ]]; then
  dset font "'Menlo 12'"
fi

             unset PROFILE_NAME
             unset PROFILE_SLUG
             unset DCONF
             unset UUIDGEN
    exit 0
  fi
fi

# Fallback for Gnome 2 and early Gnome 3
[[ -z "$GCONFTOOL" ]] && GCONFTOOL=gconftool
[[ -z "$BASE_KEY" ]] && BASE_KEY=/apps/gnome-terminal/profiles

PROFILE_KEY="$BASE_KEY/$PROFILE_SLUG"

gset() {
  local type="$1"; shift
  local key="$1"; shift
  local val="$1"; shift

  "$GCONFTOOL" --set --type "$type" "$PROFILE_KEY/$key" -- "$val"
}

# because gconftool doesn't have "append"
glist_append() {
  local type="$1"; shift
  local key="$1"; shift
  local val="$1"; shift

  local entries="$(
    {
      "$GCONFTOOL" --get "$key" | tr -d '[]' | tr , "\n" | fgrep -v "$val"
      echo "$val"
    } | head -c-1 | tr "\n" ,
  )"

  "$GCONFTOOL" --set --type list --list-type $type "$key" "[$entries]"
}

# append the Tomorrow profile to the profile list
glist_append string /apps/gnome-terminal/global/profile_list "$PROFILE_SLUG"

gset string visible_name "$PROFILE_NAME"
gset string palette "#000000000000:#F2F277777A7A:#9999CCCC9999:#FFFFCCCC6666:#66669999CCCC:#CCCC9999CCCC:#6666CCCCCCCC:#FFFFFFFFFFFF:#000000000000:#F2F277777A7A:#9999CCCC9999:#FFFFCCCC6666:#66669999CCCC:#CCCC9999CCCC:#6666CCCCCCCC:#FFFFFFFFFFFF"
gset string background_color "#2D2D2D2D2D2D"
gset string foreground_color "#CCCCCCCCCCCC"
gset string bold_color ""
gset string custom-command "'/bin/bash -ilc tmux'"
if [[ -n $(find ~/.local/share/fonts /usr/share/fonts -name Menlo-Regular.ttf) ]]; then
  gset string font "'Menlo 12'"
fi
gset bool   bold_color_same_as_fg "false"
gset bool   use_theme_colors "false"
gset bool   use_theme_background "false"
gset bool   login-shell "true"

unset PROFILE_NAME
unset PROFILE_SLUG
unset DCONF
unset UUIDGEN

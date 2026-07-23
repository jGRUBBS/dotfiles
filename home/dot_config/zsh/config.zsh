fpath=("${HOME}/.config/zsh/functions" $fpath)

autoload -Uz compinit
zsh_cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"
mkdir -p "${zsh_cache_dir}"
compinit -d "${zsh_cache_dir}/zcompdump"
unset zsh_cache_dir

for function_file in "${HOME}"/.config/zsh/functions/*(N-.); do
  autoload -Uz "${function_file:t}"
done
unset function_file

for antidote_path in \
  /opt/homebrew/opt/antidote/share/antidote/antidote.zsh \
  /usr/local/opt/antidote/share/antidote/antidote.zsh; do
  if [[ -r "${antidote_path}" ]]; then
    source "${antidote_path}"
    antidote load "${HOME}/.config/zsh/zsh_plugins.txt"
    break
  fi
done
unset antidote_path

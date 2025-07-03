alias ll="ls -lah"
alias gla="git log --graph --all"
alias gs="git status"
alias hcd="cd ~/Users/qruty/Desktop/study/university/"
alias lstu="limactl start ubu"
alias lsu="limactl shell ubu"
alias lstop="limactl stop ubu"
alias lstopf="limactl stop ubu -f"
alias pipac="source ~/my_python_env/bin/activate"
alias lstopfed="limactl stop fedora"
alias lstf="limactl start fedora"

export MANPATH="/usr/local/texlive/2024/texmf-dist/doc/man:$MANPATH"
export INFOPATH="/usr/local/texlive/2024/texmf-dist/doc/info:$INFOPATH"
export PATH="/opt/homebrew/bin:$PATH"
export EDITOR="nvim"
export VISUAL="nvim"

eval "$(direnv hook bash)"

export rtp="/Users/qruty/.opam/4.12.2+flambda/share/ocp-indent/vim:$rtp"

# BEGIN opam configuration
# This is useful if you're using opam as it adds:
#   - the correct directories to the PATH
#   - auto-completion for the opam binary
# This section can be safely removed at any time if needed.
[[ ! -r '/Users/qruty/.opam/opam-init/init.sh' ]] || source '/Users/qruty/.opam/opam-init/init.sh' > /dev/null 2> /dev/null
# END opam configuration

source /opt/homebrew/opt/chruby/share/chruby/chruby.sh

export PATH="/opt/homebrew/lib/ruby/gems/3.3.0/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk@17/bin:$PATH"
export CPPFLAGS="-I/opt/homebrew/opt/openjdk@17/include"
export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
export PATH="/opt/homebrew/lib/ruby/gems/3.4.0/bin:$PATH"

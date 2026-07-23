alias kingandpartners="open https://kingandpartners.signin.aws.amazon.com/console"
alias grandlife="open https://grandlifehotels.signin.aws.amazon.com/console"
alias auberge="open https://aubergeresorts.signin.aws.amazon.com/console"
alias jgrubbs="open https://jgrubbs.signin.aws.amazon.com/console"
alias alila="open https://239418529033.signin.aws.amazon.com/console"
alias woof="open https://914242301121.signin.aws.amazon.com/console"
alias banyantree="open https://698428315610.signin.aws.amazon.com/console"
alias wpengine="open https://my.wpengine.com/users/login"

alias size='du -sh . | awk '\''{ print "disk used in " ENVIRON["PWD"] ": " $1 }'\'''
alias count='find . -type f | wc -l | awk '\''{ print "files: " $1 }'\'''
alias dcp='bin/docker_compose'
alias fos-toggle='toggle-vscode-format-on-save'

find_in() {
  rg --line-number --word-regexp -- "${2}" "${1}"
}

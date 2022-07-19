### #!/usr/bin/env bash

source ../dev.env

export KUBERNETES_NAMESPACE=${NAME}
alias kd='kubectl -n $NAME'
status is-interactive || exit

if type -q kubectl
   alias k kubectl
   alias kg "kubectl get"
   alias kd "kubectl describe"
   alias kl "kubectl logs"
   alias kap "kubectl apply -f"
   alias krm "kubectl delete"
end

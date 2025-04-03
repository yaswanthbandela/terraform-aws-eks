for dir in 60-ingress-alb 40-eks 30-db 20-bastion 10-sg 00-vpc; do 
  echo "🚨 Destroying $dir..." && 
  cd $dir && 
  terraform destroy --auto-approve && 
  cd ..; 
  echo "✅ Done with $dir"
done

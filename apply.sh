#!/bin/bash

for dir in 00-vpc 10-sg 20-bastion 30-db 40-eks 60-ingress-alb; do
  echo "🚀 Applying Terraform in $dir..."
  cd $dir &&
  terraform init &&
  terraform apply --auto-approve &&
  cd ..
  echo "✅ Done with $dir"
done

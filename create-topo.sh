#!/bin/bash
bat snacka-k8s.clab.yml
bat --line-range 4: "${0}"
sudo -E containerlab deploy

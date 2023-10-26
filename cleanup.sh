#!/bin/bash
bat --line-range 3: "${0}"
sudo -E containerlab destroy
kind delete clusters -A

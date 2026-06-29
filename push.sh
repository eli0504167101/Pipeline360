#!/bin/bash
git add .
git commit -m "Update CI/CD pipeline"
git push origin $(git branch --show-current)
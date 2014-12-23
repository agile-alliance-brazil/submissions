#!/usr/bin/env bash
bundle exec foreman start & bundle exec guard & bundle exec rake konacha:serve

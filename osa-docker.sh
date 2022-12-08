#!/bin/bash

echo -e '\033[31m Please use osa-container.sh instead! \033[0m'

bash <(curl https://gitlab.astro.unige.ch/savchenk/osa-docker/raw/master/osa-container.sh) docker $@


#!/bin/bash

MODULE_CACHE_DIR="${TRAVIS_BUILD_DIR}/travis/module-cache/$(php-config --vernum)"
PHP_CONFIG="${TRAVIS_BUILD_DIR}/travis/phpconfig.ini"
PHP_TARGET_DIR="$(php-config --extension-dir)"

if ls "${MODULE_CACHE_DIR}"/* &> /dev/null; then
  cp "${MODULE_CACHE_DIR}"/* "${PHP_TARGET_DIR}"
fi

touch "${PHP_CONFIG}"
mkdir -p "${MODULE_CACHE_DIR}"

pecl_module_install() {
  if [ "$1" == "-f" ]; then
    force="-f"
    shift
  else
    force=""
  fi

  package="$1"
  filename="$2"

  if php -m | grep -qFx "${package%%-*}"; then
    echo "${package} is already installed and active"
  elif ! [ -f "${PHP_TARGET_DIR}/${filename}" ]; then
    echo "${filenamen is not found in extension directory, compiling..."
    pecl install ${force} ${package}
  else
    echo "Adding ${filename} to PHP config"
    echo "extension = ${filename}" >> "$PHP_CONFIG"
  fi
  cp "${PHP_TARGET_DIR}/${filename}" "$MODULE_CACHE_DIR"
}

if [ "${PECL_HTTP_VERSION%%.*}" -ge 7 ]; then
  yes | pecl_module_install raphf raphf.so
  yes | pecl_module_install propro propro.so
elif [ "${PECL_HTTP_VERSION%%.*}" -gt 1 ]; then
  yes | pecl_module_install raphf-1.1.2 raphf.so
  yes | pecl_module_install propro-1.0.2 propro.so
fi
printf "\n\n\n" | pecl_module_install -f pecl_http-${PECL_HTTP_VERSION} http.so

phpenv config-add "$PHP_CONFIG"

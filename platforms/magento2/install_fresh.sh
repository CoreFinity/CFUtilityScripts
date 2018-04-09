#!/bin/bash
#
# Install M2 environment from composer
# @see VortexCommerce/BashScripts/blob/develop/staging_setup.sh
#
# $1 path
# $2 url
# $3 platform
# $4 mysqlpassword
# $5 adminpassword
#

cd $1

composer create-project \
    --no-install \
    --repository-url=https://repo.magento.com/ \
    magento/project-community-edition magento

rsync -avz ./magento/ ./
rm -Rf ./magento/

# Add the Vortex private Packagist repo
composer config repositories.vortex composer https://repo.packagist.com/vortexcommerce/
composer config repo.packagist false

composer update

ENCRYPTION_KEY=$(echo date | md5sum | cut -f1 -d" ");

php bin/magento setup:install \
    --base-url="https://$2/" \
    --base-url-secure="https://$2/" \
    --db-host='127.0.0.1' \
    --db-name="$3" \
    --db-user="$3" \
    --db-password="$4" \
    --admin-firstname='Core' \
    --admin-lastname='Finity' \
    --admin-email='support@corefinity.com' \
    --admin-user='admin' \
    --admin-password='$5' \
    --language='en_GB' \
    --currency='GBP' \
    --timezone='Europe/London' \
    --use-rewrites='1' \
    --use-secure='1' \
    --use-secure-admin=1 \
    --session-save='redis' \
    --session-save-redis-host='127.0.0.1' \
    --admin-use-security-key='1' \
    --cache-backend='redis' \
    --cache-backend-redis-server='127.0.0.1' \
    --http-cache-hosts='127.0.0.1:8082' \
    --backend-frontname='admin' \
    && php bin/magento config:set system/full_page_cache/varnish/backend_host 127.0.0.1 \
    && php bin/magento config:set system/full_page_cache/varnish/backend_port 8082 \
    && php bin/magento sampledata:deploy \
    && composer update \
    && php bin/magento setup:upgrade \
    && php bin/magento config:set catalog/frontend/flat_catalog_product 1 \
    && php bin/magento config:set catalog/frontend/flat_catalog_category 1 \
    && php bin/magento config:set dev/js/merge_files 1 \
    && php bin/magento config:set dev/js/enable_js_bundling 1 \
    && php bin/magento config:set dev/js/minify_files 1 \
    && php bin/magento config:set dev/css/merge_css_files 1 \
    && php bin/magento config:set dev/css/minify_files 1 \
    && php bin/magento config:set dev/static/sign 1 \
    && php bin/magento config:set dev/grid/async_indexing 1 \
    && php bin/magento config:set dev/grid/async_indexing 1 \
    && php bin/magento cache:flush \
    && php bin/magento cache:enable \
    && php bin/magento setup:di:compile \
    && php bin/magento deploy:mode:set production \
    && php bin/magento indexer:reindex

composer install --no-ansi --no-dev --no-interaction --no-progress --no-scripts --optimize-autoloader
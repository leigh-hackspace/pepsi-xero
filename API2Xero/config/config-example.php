<?php
define('BASE_PATH', dirname(__FILE__) );
define('DATABASE_PATH', BASE_PATH . '/database/purchase-log.db');

// Xero Config
define("XRO_APP_TYPE", "Private");
define("OAUTH_CALLBACK", "oob");
define("XERO_CONSUMER_KEY", '');
define("XERO_CONSUMER_SECRET", '');
define("XERO_CERTIFICATE", BASE_PATH . '/config/certs/xero.cer');
define("XERO_PRIVATE_KEY", BASE_PATH . '/config/certs/xero.pem');
